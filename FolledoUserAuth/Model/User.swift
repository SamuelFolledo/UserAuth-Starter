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
    var profileImage: UIImage = kBLANKIMAGE
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
//        self.fullName = _dictionary[kFULLNAME] as! String
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
        if let imageUrl = values[kIMAGEURL] {
            user.imageUrl = imageUrl as! String
        }
        saveUserLocally(user: user)
        saveUserInBackground(user: user)
        completion(nil)
    }
}

//+++++++++++++++++++++++++   MARK: Saving user   ++++++++++++++++++++++++++++++++++
func saveUserInBackground(user: User) {
    let ref = firDatabase.child(kUSERS).child(user.userId)
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
            let userDictionary = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! [String: Any] //if snapshot exist, convert it to a dictionary, then to a user we can return
            let user = User(_dictionary: userDictionary)
            completion(user)
        } else { completion(nil) }
    }, withCancel: nil)
}

func userDictionaryFrom(user: User) -> NSDictionary { //take a user and return an NSDictionary, convert dates into strings
    let createdAt = Service.dateFormatter().string(from: user.createdAt) //convert dates to strings first
    let updatedAt = Service.dateFormatter().string(from: user.updatedAt)
    let authTypes: [String] = authTypesToString(types: user.authTypes)
    return NSDictionary(
        objects: [user.userId, user.username, user.firstName, user.lastName, user.fullName, user.email, user.phoneNumber, user.imageUrl, createdAt, updatedAt, authTypes],
        forKeys: [kUSERID as NSCopying, kUSERNAME as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kEMAIL as NSCopying, kPHONENUMBER as NSCopying, kIMAGEURL as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kAUTHTYPES as NSCopying])
}

func updateCurrentUser(withValues: [String : Any], withBlock: @escaping(_ success: Bool) -> Void) { //withBlock makes it run in the background //method that saves our current user's values offline and online
    if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
        guard let currentUser = User.currentUser() else { return }
        let userObject = userDictionaryFrom(user: currentUser).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        let ref = firDatabase.child(kUSERS).child(currentUser.userId)
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

func assignFullName(fName: String, lName: String) -> String {
    if fName != "" && lName != "" {
        return "\(fName) \(lName)"
    } else {
        return ""
    }
}

//MARK: Phone Authentication
extension User {
    class func registerUserWith(phoneNumber: String, verificationCode: String, completion: @escaping (_ error: Error?, _ shouldLogin: Bool) -> Void) {
        let verificationID = UserDefaults.standard.value(forKey: kVERIFICATIONCODE) //kVERIFICATIONCODE = "firebase_verification" //Once our user inputs phone number and request a code, firebase will send the modification code which is not the password code. This code is sent by Firebase in the background to identify if the application is actually running on the device that is requesting the code.
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: verificationID as! String, verificationCode: verificationCode)
        print("Phone = \(phoneNumber) == \(verificationCode)")
        Auth.auth().signIn(with: credentials) { (userResult, error) in //Asynchronously signs in to Firebase with the given 3rd-party credentials (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair, etc.) and returns additional identity provider data.
            if let error = error { //if there's error put false on completion's shouldLogin parameter
                completion(error, false)
            }
            fetchUserWith(userId: (userResult?.user.uid)!, completion: { (user) in //check if there is user then logged in else register
                if user != nil && user?.firstName != "" { //if user is nil and user has a first name, provides extra protection
                    saveUserLocally(user: user!) //save user in our UserDefaults. We dont need to save in background because we are already getting/fetching the user
                    completion(error, true) //call our callback function to exit and finally input the error or shouldLogin to true
                } else { //register the user
                    guard let uid: String = userResult?.user.uid else { return }
                    guard let phoneNumber = userResult?.user.phoneNumber else { return }
                    let user = User(_userId: uid, _username: "", _firstName: "", _lastName: "", _email: "", _phoneNumber: phoneNumber, _imageUrl: "", _authTypes: [.phone], _createdAt: Date(), _updatedAt: Date())
//                    let user = User(_userID: uid, _phoneNumber: phoneNumber)
                    saveUserLocally(user: user) //now we have the newly registered user, save it locally and in background
                    saveUserInBackground(user: user)
                    completion(error, false) //shouldLogin = false because we need to finish registering the user
                }
            })
        }
    }
}

func getUserImage(user: User, completion: @escaping (_ error: String?, _ image: UIImage?) -> Void) {
    guard let url = URL(string: user.imageUrl) else {
        print("no image URL found")
        completion("No image url found", nil)
        return
    }
    URLSession.shared.dataTask(with: url) { (data, response, error) in
    guard
        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
        //let mimeType = response?.mimeType, mimeType.hasPrefix("image"), //error here
        let data = data, error == nil,
        let image = UIImage(data: data)
        else {
            print("no image found")
            completion("No image found", nil)
            return
        }
        completion(nil, image) //remember to use Dispatch
//        DispatchQueue.main.async() {
//            self.image = image
//        }
    }.resume()
}
