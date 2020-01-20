//
//  UserFacebook.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 1/19/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage
import FacebookCore
import FacebookLogin
import FirebaseAuth

//get user's Profile Picture
func getFacebookProfilePic(userDetails: [String: AnyObject], completion: @escaping (_ image: UIImage?, _ error: String?) -> Void) { //from user details, get the url which contains the image, and return the image
    guard let profilePictureObj: [String: AnyObject] = userDetails["picture"] as? [String: AnyObject] else { completion(nil, "Can't get picture"); return }
    guard let data: [String: AnyObject] = profilePictureObj["data"] as? [String: AnyObject] else { completion(nil, "Can't get profile picture's data"); return }
    guard let profilePicUrlString = data["url"] as? String else { completion(nil, "Can't get profile picture's url"); return }
//    guard let profilePicUrlString = data["url"]?.absoluteString else { completion(nil, "Can't get profile picture's url"); return }
    guard let profilePicUrl = URL(string: profilePicUrlString) else { completion(nil, "Can't get picture"); return }
    do { //catch any errors
        let imageData = try Data(contentsOf: profilePicUrl) //create imageData from the pic's url
        DispatchQueue.main.async {
            let userImage = UIImage(data: imageData) //turn imageData to a UIImage
            completion(userImage, nil)
        }
    } catch let error {
        completion(nil, error.localizedDescription)
    }
}

func getFacebookUser(userDetails: [String: AnyObject], accessToken: String, completion: @escaping (_ user: User?, _ error: String?) -> Void) {
    //    let id = userDetails["id"] as? String,
    guard let firstName = userDetails["first_name"] as? String, let lastName = userDetails["last_name"] as? String, let email = userDetails["email"] as? String else { //get user details
        print("Failed to get user's facebook details")
        return
    }
    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken) //get credential
    Auth.auth().signIn(with: credential) { (userResult, error) in
        if let error = error { //sign in our user
            completion(nil, error.localizedDescription)
        }
        guard let userResult = userResult else { return }
        //                print("USER RESULT = \(userResult.additionalUserInfo?.profile)")
        if !userResult.additionalUserInfo!.isNewUser { //if not new user... get the user's info
            fetchUserWith(userId: userResult.user.uid) { (userFetched) in
                if let user = userFetched {
                    saveUserLocally(user: user)
                    saveUserInBackground(user: user)
                    completion(user, nil)
                } else {
                    completion(nil, "Failed to fetch user")
                }
            }
        } else { //first time user, get their facebook pic, store pic in Storage, and return user
            getFacebookProfilePic(userDetails: userDetails) { (profilePic, error) in //get profile picture from facebook
                if let error = error {
                    completion(nil, error)
                }
                getImageURL(id: userResult.user.uid, image: profilePic!) { (imageUrl, error) in
                    if let error = error {
                        completion(nil, error)
                    }
                    let user = User(_userId: userResult.user.uid, _username: "", _firstName: firstName, _lastName: lastName, _email: email, _phoneNumber: "", _imageUrl: imageUrl!, _authTypes: [.facebook], _createdAt: Date(), _updatedAt: Date())
                    user.profileImage = profilePic!
                    saveUserLocally(user: user)
                    saveUserInBackground(user: user)
                    saveEmailInDatabase(email: email)
                    completion(user, nil)
                }
            }
        }
    }
}
