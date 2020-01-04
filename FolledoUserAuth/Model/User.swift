//
//  User.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//


import Foundation
import Firebase
import FirebaseAuth

class User: NSObject {
    var userID: String
    var username: String
    var firstName: String
    var lastName: String
    var fullName: String
    var email: String
    var avatarURL: String
    var phoneNumber: Int

    init(_userID: String, _username: String = "", _firstName: String = "", _lastName: String = "", _email: String = "", _phoneNumber: Int = 0, _avatarURL: String = "") {
        userID = _userID
        username = _username
        firstName = _firstName
        lastName = _lastName
        fullName = "\(_firstName) \(_lastName)"
        email = _email
        phoneNumber = _phoneNumber
        avatarURL = _avatarURL
    }
    
    init(_dictionary: [String: Any]) {
        self.userID = _dictionary[kUSERID] as! String
        self.username = _dictionary[kUSERNAME] as! String
        self.firstName = _dictionary[kFIRSTNAME] as! String
        self.lastName = _dictionary[kLASTNAME] as! String
        self.fullName = _dictionary[kFULLNAME] as! String
        self.email = _dictionary[kEMAIL] as! String
        self.avatarURL = _dictionary[kAVATARURL] as! String
    }
    
    deinit {
        print("User \(self.fullName) is being deinitialize.")
    }
    
//MARK: Private Methods
    private func assignFullName() {
        if firstName != "" && lastName != "" {
            fullName = "\(firstName) \(lastName)"
        } else {
            fullName = ""
        }
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
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ user: User?) -> Void) { //do u think I should return the user here on completion?
        Auth.auth().createUser(withEmail: email, password: password) { (firUser, error) in
            if let error = error {
                completion(error,nil)
            }
            completion(nil,nil)
//            completion(nil, firUser?.user)
        }
    }
    
    class func loginUserWith(email: String, password: String, withBlock: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (firUser, error) in
            if let error = error {
                withBlock(error)
                return
            }
            guard let currentUser = firUser else { return }
            print("user is = \(currentUser.user)")
            print("user data is = \(currentUser.user.providerData)")
            print("firuser is = \(currentUser)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { //it is important to have some DELAY
                let uid: String = firUser!.user.uid
                fetchUserWith(userId: uid, completion: { (user) in
                    guard let user = user else { print("no user"); return }
                    saveUserLocally(user: user) //since fetchUserWith already calls saveUserInBackground
                    withBlock(error)
                })
            })
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
        let userRef = firDatabase.child(kUSERS).queryOrdered(byChild: kUSERID).queryEqual(toValue: user!.uid).queryLimited(toFirst: 1)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in //delete from Database
            if snapshot.exists() { //snapshot has uid and all its user's values
                firDatabase.child(kUSERS).child(user!.uid).removeValue { (error, ref) in
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
        if let avatarURL = values[kAVATARURL] {
            user.avatarURL = avatarURL as! String
        }
        saveUserLocally(user: user)
        saveUserInBackground(user: user)
        completion(nil)
    }
}

//+++++++++++++++++++++++++   MARK: Saving user   ++++++++++++++++++++++++++++++++++
func saveUserInBackground(user: User) {
    let ref = firDatabase.child(kUSERS).child(user.userID)
    ref.setValue(userDictionaryFrom(user: user))
    print("Finished saving user \(user.fullName) in Firebase")
    
    
}

//save locally
func saveUserLocally(user: User) {
    UserDefaults.standard.set(userDictionaryFrom(user: user), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
    print("Finished saving user \(user.fullName) locally...")
}

func fetchUserWith(userId: String, completion: @escaping (_ user: User?) -> Void) {
    let ref = firDatabase.child(kUSERS).queryOrdered(byChild: kUSERID).queryEqual(toValue: userId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
//        print("SNAPSHOT FROM FETCH USER IS \(snapshot)")
        if snapshot.exists() {
            let userDictionary = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! [String: Any]
            let user = User(_dictionary: userDictionary)
            completion(user)
        } else { completion(nil) }
    }, withCancel: nil)
}

func userDictionaryFrom(user: User) -> NSDictionary { //take a user and return an NSDictionary
    return NSDictionary(
        objects: [user.userID, user.username, user.firstName, user.lastName, user.fullName, user.email, user.avatarURL],
        forKeys: [kUSERID as NSCopying, kUSERNAME as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kEMAIL as NSCopying, kAVATARURL as NSCopying])
}

func updateCurrentUser(withValues: [String : Any], withBlock: @escaping(_ success: Bool) -> Void) { //withBlock makes it run in the background //method that saves our current user's values offline and online
    if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
        guard let currentUser = User.currentUser() else { return }
        let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        let ref = firDatabase.child(kUSERS).child(currentUser.userID)
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

func isUserLoggedIn() -> Bool {
    if User.currentUser() != nil {
        return true
    } else {
        return false
    }
}

func getImageURL(imageView: UIImageView, compeltion: @escaping(_ imageURL: String?, _ error: String?) -> Void) { //method that grabs an image from a UIImageView, compress it as JPEG, store in Storage, and returning the URL if no error
    let imageName = NSUUID().uuidString
    let imageReference = Storage.storage().reference().child("avatar_images").child("0000\(imageName).png")
    if let avatarImage = imageView.image, let uploadData = avatarImage.jpegData(compressionQuality: 0.35) { //compress the image to be uploaded
        imageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in //putData = Asynchronously uploads data to the reference
            if let error = error {
                compeltion(nil, error.localizedDescription)
            } else { //if no error, get the url
                imageReference.downloadURL(completion: { (imageUrl, error) in
                    if let error = error {
                        compeltion(nil, error.localizedDescription)
                    } else { //no error on downloading metadata URL
                        guard let url = imageUrl?.absoluteString else { return }
                        compeltion(url, nil)
                    }
                })
            }
        })
    }
}

func saveEmailInDatabase(email:String) { //saves email address as the key, converting the email's last @ to _-_
    let convertedEmail = email.emailEncryptedForFirebase()
    let emailRef = firDatabase.child(kREGISTEREDUSERS).child(convertedEmail)
    emailRef.updateChildValues([kEMAIL:email])
}
