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
    var firstName: String
    var lastName: String
    var fullName: String
    var email: String
    var avatarURL: String
    var userID: String

    init(_userID: String, _firstName: String, _lastName: String, _email: String, _avatarURL: String = "") {
        userID = _userID
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + _lastName
        email = _email
        avatarURL = _avatarURL
    }
    
    init(_dictionary: [String: Any]) {
        self.userID = _dictionary[kUSERID] as! String
        self.firstName = _dictionary[kFIRSTNAME] as! String
        self.lastName = _dictionary[kLASTNAME] as! String
        self.fullName = _dictionary[kFULLNAME] as! String
        self.email = _dictionary[kEMAIL] as! String
        self.avatarURL = _dictionary[kAVATARURL] as! String
    }
    
    deinit {
        print("User \(self.fullName) is being deinitialize.")
    }
    
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
    
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (firUser, error) in
            if let error = error {
                completion(error)
                return
            }
            completion(error)
        }
    }
    
    class func loginUserWith(email: String, password: String, withBlock: @escaping (_ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (firUser, error) in
            if let error = error {
                withBlock(error)
                return
            }
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
        user?.delete(completion: { (error) in
            completion(error)
        })
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
        objects: [user.userID, user.firstName, user.lastName, user.fullName, user.email, user.avatarURL],
        forKeys: [kUSERID as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kEMAIL as NSCopying, kAVATARURL as NSCopying])
}


func updateCurrentUser(withValues: [String : Any], withBlock: @escaping(_ success: Bool) -> Void) { //withBlock makes it run in the background //method that saves our current user's values offline and online
    if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
        guard let currentUser = User.currentUser() else { return }
        let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary //OneSignal S3 ep. 24 4mins
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
