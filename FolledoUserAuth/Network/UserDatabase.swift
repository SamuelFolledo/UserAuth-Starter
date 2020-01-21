//
//  UserDatabase.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 1/19/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Firebase

//MARK: Create/Save User
func saveUserInBackground(user: User) { //save user in Firebase
    let ref = firDatabase.child(kUSER).child(user.userId)
    ref.setValue(userDictionaryFrom(user: user))
    print("Finished saving user \(user.fullName) in Firebase")
}

func saveUserLocally(user: User) { //save user to UserDefaults
    UserDefaults.standard.set(userDictionaryFrom(user: user), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
    print("Finished saving user \(user.fullName) locally...")
}

func saveEmailInDatabase(email:String) { //saves an extra copy of email address as the key, converting the email's last @ to _-_
    let convertedEmail = email.emailEncryptedForFirebase() //for key
    let emailRef = firDatabase.child(kREGISTEREDUSERS).child(convertedEmail)
    emailRef.updateChildValues([kEMAIL:email])
}

//MARK: Read User
func fetchUserWith(userId: String, completion: @escaping (_ user: User?) -> Void) { //get a user from Firebase Database with userId
    let ref = firDatabase.child(kUSER).queryOrdered(byChild: kUSERID).queryEqual(toValue: userId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        if snapshot.exists() {
            let userDictionary = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! [String: Any] //if snapshot exist, convert it to a dictionary, then to a user we can return
            let user = User(_dictionary: userDictionary)
            completion(user)
        } else { completion(nil) }
    }, withCancel: nil)
}

//MARK: Update User
func updateCurrentUser(withValues: [String : Any], withBlock: @escaping(_ success: Bool) -> Void) { //withBlock makes it run in the background //method that saves our current user's values offline and online
    if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
        guard let currentUser = User.currentUser() else { return }
        let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        let ref = firDatabase.child(kUSER).child(currentUser.userId)
        ref.updateChildValues(withValues) { (error, ref) in
            if error != nil {
                withBlock(false)
                return
            }
            UserDefaults.standard.set(userObject, forKey: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            withBlock(true)
        }
    }
}

//MARK: Phone Authentication
extension User {
    class func authenticateUser(credential: AuthCredential, userDetails: [String: Any], completion: @escaping (_ user: User?, _ error: String?) -> Void) { //authenticate user given 3rd-party credentials (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair, Phone, etc.) and return a user or error
    //1) get user properties from userDetails, else empty or default
        let firstName: String = userDetails[kFIRSTNAME] as? String ?? ""
        let lastName: String = userDetails[kLASTNAME] as? String ?? ""
        let userName: String = userDetails[kFIRSTNAME] as? String ?? ""
        let email: String = userDetails[kLASTNAME] as? String ?? ""
        let phoneNumber: String = userDetails[kLASTNAME] as? String ?? ""
        let imageUrl: String = userDetails[kFIRSTNAME] as? String ?? ""
        let profileImage: UIImage = userDetails[kPROFILEIMAGE] as? UIImage ?? kDEFAULTPROFILEIMAGE
        let createdAt: Date = userDetails[kCREATEDAT] as? Date ?? Date()
        let updatedAt: Date = userDetails[kUPDATEDAT] as? Date ?? Date()
        let authTypes: [AuthType] = userDetails[kAUTHTYPES] as? [AuthType] ?? []
        
        Auth.auth().signIn(with: credential) { (userResult, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            guard let userResult = userResult else {
                completion(nil, "No user results found")
                return
            }
            let user: User = User(_userId: userResult.user.uid, _username: userName, _firstName: firstName, _lastName: lastName, _email: email, _phoneNumber: phoneNumber, _imageUrl: imageUrl, _authTypes: authTypes, _createdAt: createdAt, _updatedAt: updatedAt)
            print("PROVIDER = \(userResult.additionalUserInfo?.providerID)")
            if userResult.additionalUserInfo!.isNewUser { //if new user, REGISTER and SAVE
                saveUserLocally(user: user)
                saveUserInBackground(user: user)
                completion(user, nil)
            } else { //if not new user LOGIN and UPDATE
                fetchUserWith(userId: user.userId) { (user) in
                    guard let user = user else {
                        completion(nil, "Error fetching user")
                        return
                    }
                    user.updatedAt = Date() //update user's updatedAt
                    if user.imageUrl != "" { //if user has image
                        getUserImage(user: user) { (error, image) in
                            if let error = error {
                                completion(nil, error)
                            }
                            user.profileImage = image!
                            saveUserLocally(user: user)
                            saveUserInBackground(user: user)
                        }
                    } else { //if user has no image...
                        user.profileImage = profileImage //default profileImage
                        saveUserLocally(user: user)
                        saveUserInBackground(user: user)
                    }
                }
            }
        }
    }
    
    class func registerUserWith(phoneNumber: String, verificationCode: String, completion: @escaping (_ error: String?, _ shouldLogin: Bool) -> Void) {
        let verificationID = UserDefaults.standard.value(forKey: kVERIFICATIONCODE) //kVERIFICATIONCODE = "firebase_verification" //Once our user inputs phone number and request a code, firebase will send the modification code which is not the password code. This code is sent by Firebase in the background to identify if the application is actually running on the device that is requesting the code.
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID as! String, verificationCode: verificationCode)
        print("Phone = \(phoneNumber) == \(verificationCode)")
        Auth.auth().signIn(with: credentials) { (userResult, error) in //Asynchronously signs in to Firebase with the given 3rd-party credentials (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair, etc.) and returns additional identity provider data.
            if let error = error { //if there's error put false on completion's shouldLogin parameter
                completion(error.localizedDescription, false)
            }
            guard let userResult = userResult else { return } //userResult contains lots of important info we will need in the future
            //            print("USER RESULT = \(userResult)\nUSER ADDITIONAL INFO = \(userResult.additionalUserInfo)\n\n \(userResult.credential)")
            let user: User = User(_userId: userResult.user.uid, _username: "", _firstName: "", _lastName: "", _email: "", _phoneNumber: userResult.user.phoneNumber!, _imageUrl: "", _authTypes: [.phone], _createdAt: Date(), _updatedAt: Date())
            if userResult.additionalUserInfo!.isNewUser { //if new user, save locally and finish registering
                saveUserLocally(user: user) //now we have the newly registered user, save it locally and in background
                saveUserInBackground(user: user)
                completion(nil, false) //shouldLogin = false because we need to finish registering the user
            } else { //login
                fetchUserWith(userId: user.userId) { (user) in
                    saveUserLocally(user: user!) //we dont need to save in background because we are already getting/fetching the user
                    if user != nil && user?.firstName != "" { //if user is nil and user has a first name, provides extra protection
                        completion(nil, false) //this will rarely get executed, but just in case we have a user who for some reason is not first time but has no first name
                    } else { //user has previous finished registering, so we can log them in
                        completion(nil, true)
                    }
                }
            }
        }
    }
}

func registerUserEmailIntoDatabase(user: User, completion: @escaping (_ error: Error?, _ user: User?) -> Void) { //similar to registerUserIntoDatabaseWithUID, but this accepts a user instead of uid and values
    let usersReference = firDatabase.child(kUSER).child(user.userId)
    usersReference.setValue(userDictionaryFrom(user: user), withCompletionBlock: { (error, ref) in
        if let error = error {
            completion(error, nil)
        } else { //if no error, save user
            saveEmailInDatabase(email:user.email) //MARK: save to another table
                saveUserLocally(user: user)
                saveUserInBackground(user: user)
                completion(nil, user)
//            }
        }
    })
}

func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any], completion: @escaping (_ error: String?, _ user: User?) -> Void) { //method that gets uid and a dictionary of values you want to give to users
    let usersReference = firDatabase.child(kUSER).child(uid)
    usersReference.setValue(values, withCompletionBlock: { (error, ref) in
        if let error = error {
            completion(error.localizedDescription, nil)
        } else { //if no error, save user
            saveEmailInDatabase(email:values[kEMAIL] as! String) //MARK: save to another table
            DispatchQueue.main.async {
                let user = User(_dictionary: values)
                saveUserLocally(user: user)
                saveUserInBackground(user: user)
                completion(nil, user)
            }
        }
    })
}
