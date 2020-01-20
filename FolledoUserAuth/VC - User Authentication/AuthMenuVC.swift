//
//  AuthMenuVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage
import FacebookCore
import FacebookLogin
import FirebaseAuth

class AuthMenuVC: UIViewController {
    
//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: FBLoginButton!
    @IBOutlet weak var anonymousButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
//MARK: Properties
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUp()
    }
    
//MARK: Methods
    func setUp() {
        anonymousButton.isAuthButton()
        setupFacebookButton()
        googleButton.isAuthButton()
        phoneButton.isAuthButton()
        emailButton.isAuthButton()
    }
    
//MARK: IBActions
    @IBAction func emailButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: true)
    }
    @IBAction func phoneButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: false)
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Google is still under production. Check back at a later time")
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        //        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Facebook is still under production. Check back at a later time")
    }
    
    @IBAction func anonymousButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Anonymous is still under production. Check back at a later time")
    }
    
//MARK: Helpers
    fileprivate func setupFacebookButton() { //setup facebook button and its font size
        facebookButton.isAuthButton()
//        let fbButton = FBLoginButton(frame: facebookButton.center, permissions: [.publicProfile]) //programmatically create one
        facebookButton.permissions = [ "public_profile", "email", "user_photos"] //get public profile, email, photos, and about me
        let font = UIFont.boldSystemFont(ofSize: 18) //bold system, size 18
        let fbTitle = NSAttributedString.init(string: "Continue with Facebook", attributes: [NSAttributedString.Key.font : font])
        facebookButton.setAttributedTitle(fbTitle, for: .normal)
        facebookButton.delegate = self
    }
}

//MARK: Facebook Auth
extension AuthMenuVC: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) { //Delegate method that will run once login has been completed with Facebook button. Result can be, fail, cancel, or success
        if let error = error {
            Service.presentAlert(on: self, title: "Facebook Error", message: error.localizedDescription)
            return
        }
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView() as UIActivityIndicatorView
        spinner.style = .large
        spinner.center = view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        guard let result = result else { return }
        if result.isCancelled { //if user canceled login
            print("User canceled Facebook Login")
            spinner.stopAnimating()
        } else { //if fb login is successful
            if result.grantedPermissions.contains("email") { //make sure they gave us permissions
                let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name, picture.type(large)"])
                graphRequest.start { (connection, graphResult, error) in //start a connection with Graph API
                    if let error = error {
                        spinner.stopAnimating()
                        Service.presentAlert(on: self, title: "Facebook Error", message: error.localizedDescription)
                        return
                    } else {
                        guard let userDetails: [String: AnyObject] = graphResult as? [String: AnyObject] else { //contain user's details
                            spinner.stopAnimating()
                            print("No User Details")
                            return
                        }
                        print("USER DETAILS = \(userDetails)")
                        self.fetchFacebookUserWithUserDetails(userDetails: userDetails)
                    }
                }
                spinner.stopAnimating()
            } else { //result.grantedPermissions = false
                spinner.stopAnimating()
                Service.presentAlert(on: self, title: "Facebook Error", message: "Facebook failed to grant access")
                return
            }
        }
        print("Successfully logged in Facebook")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) { //Delegate Method - Logout
        print("User logged out!")
    }
    
    fileprivate func fetchFacebookUserWithUserDetails(userDetails: [String: AnyObject]) { //fetch user's details from facebook and create that user class and go to next controller
        //spinner
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView() as UIActivityIndicatorView
        spinner.style = .large
        spinner.center = view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
//        let id = userDetails["id"] as? String,
        guard let firstName = userDetails["first_name"] as? String, let lastName = userDetails["last_name"] as? String, let email = userDetails["email"] as? String else { //get user details
            print("Failed to get user's facebook details")
            return
        }
        guard let accessToken = AccessToken.current?.tokenString else { print("Failed to get current Facebook token"); return }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken) //get credential
        getFacebookProfilePic(userDetails: userDetails) { (profilePic, error) in //get profile picture from facebook
            if let error = error {
                Service.presentAlert(on: self, title: "Error Getting Profile Pic", message: error)
                return
            }
            Auth.auth().signIn(with: credential) { (userResult, error) in
                if let error = error { //sign our user in
                    Service.presentAlert(on: self, title: "Facebook Auth Error", message: error.localizedDescription)
                    return
                }
                guard let userResult = userResult else { return }
                getImageURL(id: userResult.user.uid, image: profilePic!) { (imageUrl, error) in
                    if let error = error {
                        Service.presentAlert(on: self, title: "Image Not Stored", message: error)
                        return
                    }
                    let user: User = User(_userId: userResult.user.uid, _username: "", _firstName: firstName, _lastName: lastName, _email: email, _phoneNumber: "", _imageUrl: imageUrl!, _authTypes: [.facebook], _createdAt: Date(), _updatedAt: Date())
                    user.profileImage = profilePic!
                    saveUserLocally(user: user)
                    saveUserInBackground(user: user)
                    saveEmailInDatabase(email: email)
                    goToNextController(vc: self, user: user)
                }
            }
        }
//        spinner.stopAnimating()
//        self.dismiss(animated: true, completion: nil)

    
            //unwrap the user's profile picture
//            if let profilePictureObj: [String: AnyObject] = userDetails["picture"] as? [String: AnyObject]  {
//                guard let data: [String: AnyObject] = profilePictureObj["data"] as? [String: AnyObject] else { return }
//                guard let profilePicUrlString = data["url"]?.absoluteString else { return }
//                guard let profilePicUrl = URL(string: profilePicUrlString!) else{ return }
//                do { //catch any errors
//                    let imageData = try Data(contentsOf: profilePicUrl) //create imageData from the pic's url
//                    DispatchQueue.main.async {
//                        let userProfileImage = UIImage(data: imageData) //turn imageData to a UIImage
//                    }
//                } catch let error {
//                    Service.presentAlert(on: self, title: "Error fetching image", message: error.localizedDescription)
//                    return
//                }
//
//
//
//                //what to do with profile pic
//                let imageName = NSUUID().uuidString
//                let imageReference = Storage.storage().reference().child("profile_images").child("00FB\(imageName).png") //create the reference
//                guard let uploadData = loginLogoImageView.image!.jpegData(compressionQuality: 0.8) else { return }
//                imageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in //put the data to the imageReference
//                    if let error = error {
//                        Service.presentAlert(on: self, title: "Image to databse error", message: error.localizedDescription)
//                    } else { //if no error putting data to the database...
//
//                        let userName:String = userDetails["name"] as! String
//                        let email:String = userDetails["email"] as! String
//
//                        let values: [String: AnyObject] = ["name": userName, "email": email, "profileImageUrl": profilePicUrlString, "userUid": id] as [String: AnyObject]
//
//
//                        self.registerUserIntoDatabaseWithUID(uid: id, values: values) //register with Facebook
//
//
//
//                        //dataTask
//                        //                        URLSession.shared.dataTask(with: profilePicUrl, completionHandler: { (data, response, error) in
//                        //                            if let error = error {
//                        //                                Service.presentAlert(on: self, title: "Error", message: error.localizedDescription)
//                        //                            }
//                        //                            guard let fbCurrentUserTokenString = FBSDKAccessToken.current()?.tokenString else { return }
//                        //                            let credential = FacebookAuthProvider.credential(withAccessToken: fbCurrentUserTokenString) //our facebook token //After a user successfully signs in, in your implementation of didCompleteWithResult:error:, get an access token for the signed-in user and exchange it for a Firebase credential:
//                        //                            Auth.auth().signInAndRetrieveData(with: credential, completion: { (result, error) in //Finally, authenticate with Firebase using the Firebase credential:
//                        //                                if let error = error {
//                        //                                    Service.presentAlert(on: self, title: "Facebook Signin Error", message: error.localizedDescription)
//                        //                                }
//                        //                            //user is signed in
//                        //
//                        //                            })
//                        //
//                        //                        })
//                    }
//                }) //end of putData, already error checked
//            } else { //cant unwrap profilePictureObj
//                Service.presentAlert(on: self, title: "Facebook Error", message: "Failed to Get Profile Picture")
//            }
//        } else { //cant get userDetails["id"]
//            Service.presentAlert(on: self, title: "Facebook Error", message: "Failed to get User's Identification")
//            return
//        }
        spinner.stopAnimating()
    }
}
