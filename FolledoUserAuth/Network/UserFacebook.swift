//
//  UserFacebook.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 1/19/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

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
