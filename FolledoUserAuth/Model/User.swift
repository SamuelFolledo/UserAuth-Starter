//
//  User.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//


import Foundation
import FirebaseAuth

class User: NSObject {
    let userId: String
    var username: String
    var firstName: String
    var lastName: String
    var fullName: String
    var email: String
    var imageUrl: String {
        didSet {
            print("Put image here")
        }
    }
    var phoneNumber: String
    var profileImage: UIImage = kDEFAULTPROFILEIMAGE
    let createdAt: Date
    var updatedAt: Date
    var authTypes: [AuthType]

    init(_userId: String, _username: String = "", _firstName: String = "", _lastName: String = "", _email: String = "", _phoneNumber: String = "", _imageUrl: String = "", _authTypes: [AuthType] = [.unknown], _createdAt: Date, _updatedAt: Date) {
        userId = _userId
        username = _username
        firstName = _firstName
        lastName = _lastName
        fullName = assignFullName(fName: _firstName, lName: _lastName)
        email = _email
        phoneNumber = _phoneNumber
        imageUrl = _imageUrl
        createdAt = _createdAt
        updatedAt = _updatedAt
        authTypes = _authTypes
    }
    
    init(_dictionary: [String: Any]) {
        self.userId = _dictionary[kUSERID] as! String
        self.username = _dictionary[kUSERNAME] as! String
        self.firstName = _dictionary[kFIRSTNAME] as! String
        self.lastName = _dictionary[kLASTNAME] as! String
        if let fullName = _dictionary[kFULLNAME] as? String {
            self.fullName = fullName
        } else {
            self.fullName = assignFullName(fName: self.firstName, lName: self.lastName)
        }
        self.email = _dictionary[kEMAIL] as! String
        if let phoneNumber = _dictionary[kPHONENUMBER] as? String {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = ""
        }
        self.imageUrl = _dictionary[kIMAGEURL] as! String
        if let createdAt = _dictionary[kCREATEDAT] { //if we have this date, then apply it to the user, else create new current instance of Date()
            self.createdAt = Service.dateFormatter().date(from: createdAt as! String)!
        } else {
            self.createdAt = Date()
        }
        if let updatedAt = _dictionary[kUPDATEDAT] { //if we have this date, then apply it to the user, else create new current instance of Date()
            self.updatedAt = Service.dateFormatter().date(from: updatedAt as! String)!
        } else {
            self.updatedAt = Date()
        }
        if let authTypes = _dictionary[kAUTHTYPES] as? [AuthType] {
            print("Auth types as [AuthType]")
            self.authTypes = authTypes
        } else if let authTypes = _dictionary[kAUTHTYPES] as? [String] {
            print("Auth types as [String]")
            var resultTypes: [AuthType] = []
            for authType in authTypes {
                resultTypes.append(AuthType(type: authType))
            }
            self.authTypes = resultTypes
        } else {
            self.authTypes = []
        }
    }
    
    deinit {
        print("User \(self.fullName) is being deinitialize.")
    }
    
//MARK: Class Functions
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> User? {
        if Auth.auth().currentUser != nil { //if we have user...
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return User.init(_dictionary: dictionary as! [String: Any])
            }
        }
        return nil //if we dont have user in our UserDefaults, then return nil
    }
    
//MARK: Email Authentication
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) { //do u think I should return the user here on completion?
        Auth.auth().createUser(withEmail: email, password: password) { (firUser, error) in
            if let error = error {
                completion(error.localizedDescription,nil)
            }
            guard let user = firUser?.user else {
                print("User not found after attempt to register")
                completion(("User not found after attempt to register"), nil)
                return }
            let currentUser = User(_userId: user.uid, _username: "", _firstName: "", _lastName: "", _email: email, _phoneNumber: "", _imageUrl: "", _authTypes: [AuthType.email], _createdAt: Date(), _updatedAt: Date())
            registerUserEmailIntoDatabase(user: currentUser) { (error, user) in
                if let error = error {
                    completion(error.localizedDescription, nil)
                }
                completion(nil, user!)
            }
        }
    }
    
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (userDetails, error) in
            if let error = error {
                completion(error)
                return
            }
            guard let userDetails = userDetails else { return }
            if userDetails.additionalUserInfo!.isNewUser { //if new user
                let user: User = User(_userId: userDetails.user.uid, _username: "", _firstName: "", _lastName: "", _email: email, _phoneNumber: "", _imageUrl: "", _authTypes: [.email], _createdAt: Date(), _updatedAt: Date())
                saveUserLocally(user: user)
                saveUserInBackground(user: user)
                saveEmailInDatabase(email: user.email)
                completion(nil)
            } else { //if not user's first time...
                fetchUserWith(userId: userDetails.user.uid) { (user) in
                    if let user = user {
                        user.updatedAt = Date()
                        saveUserLocally(user: user)
                        saveUserInBackground(user: user)
                        completion(nil)
                    } else {
                        print("No user fetched from \(String(describing: userDetails.user.email))")
                    }
                }
            }
        }
    }
    
//MARK: Logout
    class func logOutCurrentUser(withBlock: (_ success: Bool) -> Void) {
        print("Logging outttt...")
        UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
        UserDefaults.standard.synchronize() //save the changes
        do {
            try Auth.auth().signOut()
            withBlock(true)
        } catch let error as NSError {
            print("error logging out \(error.localizedDescription)")
            withBlock(false)
        }
    }
    
    class func deleteUser(completion: @escaping(_ error: Error?) -> Void) { //delete the current user
        let user = Auth.auth().currentUser
        let userRef = firDatabase.child(kUSER).queryOrdered(byChild: kUSERID).queryEqual(toValue: user!.uid).queryLimited(toFirst: 1)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in //delete from Database
            if snapshot.exists() { //snapshot has uid and all its user's values
                firDatabase.child(kUSER).child(user!.uid).removeValue { (error, ref) in
                    completion(error)
                }
                firDatabase.child(kREGISTEREDUSERS).child(user!.email!.emailEncryptedForFirebase()).removeValue { (error, ref) in //remove email reference in kREGISTEREDUSERS as well
                    completion(error)
                }
            }
        }, withCancel: nil)
        user?.delete(completion: { (error) in //delete from Authentication
            completion(error)
        })
    }
    
    class func updateCurrentUser(values: [String:Any], completion: @escaping (_ error: String?) -> Void) { //update anything but userID
        guard let user = self.currentUser() else { return }
        if let username = values[kUSERNAME] {
            user.username = username as! String
        }
        if let firstName = values[kFIRSTNAME] {
            user.firstName = firstName as! String
        }
        if let lastName = values[kLASTNAME] {
            user.lastName = lastName as! String
        }
        user.fullName = "\(user.firstName) \(user.lastName)"
        if let email = values[kEMAIL] {
            user.email = email as! String
        }
        if let imageUrl = values[kIMAGEURL] {
            user.imageUrl = imageUrl as! String
        }
        saveUserLocally(user: user)
        saveUserInBackground(user: user)
        completion(nil)
    }
}

//MARK: Helper Methods for User
func userDictionaryFrom(user: User) -> NSDictionary { //take a user and return an NSDictionary, convert dates into strings
    let createdAt = Service.dateFormatter().string(from: user.createdAt) //convert dates to strings first
    let updatedAt = Service.dateFormatter().string(from: user.updatedAt)
    let authTypes: [String] = authTypesToString(types: user.authTypes)
    return NSDictionary(
        objects: [user.userId, user.username, user.firstName, user.lastName, user.fullName, user.email, user.phoneNumber, user.imageUrl, createdAt, updatedAt, authTypes],
        forKeys: [kUSERID as NSCopying, kUSERNAME as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kEMAIL as NSCopying, kPHONENUMBER as NSCopying, kIMAGEURL as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kAUTHTYPES as NSCopying])
}

func isUserLoggedIn() -> Bool { //checks if we have user logged in
    if User.currentUser() != nil {
        return true
    } else {
        return false
    }
}

func assignFullName(fName: String, lName: String) -> String { //returns full name if first name and last name is not empty
    if fName.trimmedString() != "" && lName.trimmedString() != "" {
        return "\(fName) \(lName)"
    } else {
        return ""
    }
}
