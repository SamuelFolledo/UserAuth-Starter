//
//  ProfileVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
      
//MARK: Properties
    
    
    
    
//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
            
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    
        
        
//MARK: Methods
    func setUp() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        
    }
     
//    func submit(){
//
//        guard let name = nameTextField.text?.trimmedString() else {
//                   nameView.layer.borderColor = kREDCGCOLOR; return
//               }
//
//        if !(name.isValidName) {
//            self.nameView.layer.borderColor = kREDCGCOLOR
//            errorCounter += 1
//            Service.presentAlert(on: self, title: "Invalid Name Format", message: "Name must only be US letters (ex. Samuel, Samuel Folledo, Samuel P Folledo, or Samuel P. Folledo)")
//        } else {
//            self.nameView.layer.borderColor = kCLEARCGCOLOR
//        }
//
//    }
    
//    private func register() {
//            var errorCounter = 0
//            let methodStart = Date()
//            
//            guard let email = emailTextField.text?.trimmedString() else {
//                emailTextField.layer.borderColor = kREDCGCOLOR; return
//            }
//            guard let password = passwordTextField.text?.trimmedString() else {
//                passwordTextField.layer.borderColor = kREDCGCOLOR; return
//            }
//            
//            if !(email.isValidEmail) { //if email is not valid
//                self.emailView.layer.borderColor = kREDCGCOLOR
//                errorCounter += 1
//                Service.presentAlert(on: self, title: "Invalid Email Format", message: "Email format is not valid. Please try again with correct or another email")
//            } else {
//                self.emailView.layer.borderColor = kCLEARCGCOLOR
//            }
//                    
//            if password.count < 6 {
//                errorCounter += 1
//                passwordTextField.layer.borderColor = kREDCGCOLOR
//                Service.presentAlert(on: self, title: "Password Count Error", message: "Password must be at least 6 characters")
//            } else {
//                passwordTextField.layer.borderColor = kCLEARCGCOLOR
//            }
//            
//            print("there are \(errorCounter) errors")
//            
//            switch errorCounter {
//            case 0: //if 0 errorCounter... Register
//                
//                User.registerUserWith(email: email, password: password) { (error) in
//                    if let error = error {
//                        Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
//                    } else { //if no error registering user...
//                        
//                        let imageName = NSUUID().uuidString
//                        let imageReference = Storage.storage().reference().child("avatar_images").child("0000\(imageName).png")
//                        
//                        if let avatarImage = self.avatarImageView.image, let uploadData = avatarImage.jpegData(compressionQuality: 0.5) { //compress the image to be uploaded
//                            imageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in //putData = Asynchronously uploads data to the reference
//                                if let error = error {
//                                    Service.presentAlert(on: self, title: "Error Putting Image", message: error.localizedDescription)
//                                    User.deleteUser(completion: { (error) in
//                                        if let error = error {
//                                            Service.presentAlert(on: self, title: "Error Deleting User", message: error.localizedDescription)
//                                        }
//                                    })
//                                    return
//                                } else { //if no error
//                                    imageReference.downloadURL(completion: { (imageUrl, error) in
//                                        if let error = error {
//                                            Service.presentAlert(on: self, title: "Error Downloading Image", message: error.localizedDescription)
//                                        } else { //no error on downloading metadata URL
//                                            
//                                            let uid = User.currentId()
//                                            guard let url = imageUrl?.absoluteString else { return }
//                                            let oneSignalId: String? = UserDefaults.standard.string(forKey: kONESIGNALID)
//                                            print("OneSignal Id = \(oneSignalId)")
//                                            let pushId: String = oneSignalId == nil || oneSignalId == "" ? "" : oneSignalId!
//    //                                        let values = [kNAME: name, kEMAIL: email, kAVATARURL: url, kUSERID: uid, kWINS: 0, kLOSES: 0, kMATCHESUID: [], kMATCHESDICTIONARY:[], kEXPERIENCES: 0, kLEVEL: 0 ] as [String : Any] //pass the url
//                                            let values = [kNAME: name, kEMAIL: email, kAVATARURL: url, kUSERID: uid, kWINS: 0, kLOSES: 0, kMATCHESUID: [], kMATCHESDICTIONARY:[], kEXPERIENCES: 0, kLEVEL: 0, kPUSHID: pushId] as [String : Any] //pass the url
//                                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
//                                            
//                                            //finished registering!
//                                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//                                                let methodFinish = Date()
//                                                let executionTime = methodFinish.timeIntervalSince(methodStart) //to get the executionTime
//                                                
//                                                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
//                                                    self.navigationController?.popToRootViewController(animated: true)
//                                                }
//                                                Service.alertWithActions(on: self, actions: [okAction], title: "Success!", message: "Successfully logged in \(executionTime) milliseconds")
//                                                
//                                            })
//                                        }
//                                    })
//                                    
//                                }
//                            })
//                        }
//                    }
//                }
//                
//            default:
//                Service.presentAlert(on: self, title: "Error", message: "There are errors on the field. Please try again.")
//            }
//        }
        
        
        
        private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any] ) {
            
    //        let ref = Database.database().reference()
            let usersReference = firDatabase.child(kUSERS).child(uid)
            usersReference.setValue(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
                    return
                } else {
                    print("user reference created successfully")
                    let gameStatsValues = [kWINS: 0, kLOSES: 0, kMATCHESUID: [], kMATCHESDICTIONARY:[], kEXPERIENCES: 0, kLEVEL: 0] as [String : Any] //pass the url
                    
                    let gameRef = usersReference.child(kGAMESTATS) //this is the reference for user's win, lose, and experience stats
                    gameRef.setValue(gameStatsValues, withCompletionBlock: { (error, ref) in
                        if let error = error {
                            Service.presentAlert(on: self, title: "Firebase Register Error", message: error.localizedDescription)
                            return
                        } else {
                            
                            DispatchQueue.main.async {
                                let user = User(_dictionary: values)
                                saveUserLocally(user: user)
                                saveUserInBackground(user: user)
                            }
                        }
                    })
                }
            })
        }

        
//MARK: IBActions
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
        

}
