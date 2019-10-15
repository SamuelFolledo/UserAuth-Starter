//
//  ProfileVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileVC: UIViewController {
    
//MARK: Properties
    var userImagePicker: UIImagePickerController?
    var imageAdded = false
    var imageName = ""
    
    
//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
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
        userImageView.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(handleUpdateProfileImage))
        userImageView.addGestureRecognizer(imageTap)
        userImageView.rounded()
        userImagePicker = UIImagePickerController()
        userImagePicker?.delegate = self
    }
    
//MARK: IBActions
    @IBAction func submitButtonTapped(_ sender: Any) {
        let inputValues: (errorCount: Int, firstName: String, lastName: String, username: String) = checkInputValues()
        switch inputValues.errorCount {
        case 0:
            getImageURL(imageView: userImageView) { (imageURL, error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Error Uploading Image", message: error)
                } else {
                    let userValues: [String: Any] = [kFIRSTNAME: inputValues.firstName, kLASTNAME: inputValues.lastName, kUSERNAME: inputValues.username, kAVATARURL: imageURL!]
                    User.updateCurrentUser(values: userValues) { (error) in
                        if let error = error {
                            Service.presentAlert(on: self, title: "Error Updating User", message: error)
                        } else {
                            print("Successfuly updated user! \(userDictionaryFrom(user: User.currentUser()!))")
                            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        default:
            Service.presentAlert(on: self, title: "Error", message: "There are errors on the field. Please try again.")
            return
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) { //delete user if they went back
        User.deleteUser(completion: { (error) in
            if let error = error {
                Service.presentAlert(on: self, title: "Error Deleting User", message: error.localizedDescription)
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    @objc func handleUpdateProfileImage() {
        let optionMenu = UIAlertController(title: "Update Photo Using?", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.userImagePicker?.sourceType = .camera
            self.userImagePicker?.allowsEditing = true
            self.present(self.userImagePicker!, animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (alert) in
            self.userImagePicker?.sourceType = .photoLibrary
            self.userImagePicker?.allowsEditing = true
            self.present(self.userImagePicker!, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            optionMenu.dismiss(animated: true, completion: nil)
        }

        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(cancelAction)
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = self.userImageView
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    fileprivate func checkInputValues() -> (errorCount: Int, firstName: String, lastName: String, username: String) { //method that check for errors on input values from textfields, put a red border or clear border and return input values with errorCount
        var values: (errorCount: Int, firstName: String, lastName: String, username: String) = (0, "", "", "")
        if let firstName = firstTextField.text?.trimmedString() { //check if first name exists
            if !(firstName.isValidName) { //if name is not valid
                firstTextField.hasError()
                values.errorCount += 1
                Service.presentAlert(on: self, title: "Invalid First Name", message: "First name format is not valid, please use characters and whitespace only")
            } else {
                values.firstName = firstName
                firstTextField.hasNoError()
            }
        } else {
            firstTextField.hasError(); values.errorCount += 1
            Service.presentAlert(on: self, title: "Invalid Last Name", message: "Field is empty")
        }
        if let lastName = lastTextField.text?.trimmedString() { //if last name exists
            if !(lastName.isValidName) { //if name is not valid
                lastTextField.hasError()
                values.errorCount += 1
                Service.presentAlert(on: self, title: "Invalid Last Name", message: "Last name format is not valid, please use characters and whitespace only")
            } else {
                values.lastName = lastName
                lastTextField.hasNoError()
            }
        } else {
            lastTextField.hasError(); values.errorCount += 1
            Service.presentAlert(on: self, title: "Invalid Last Name", message: "Field is empty")
        }
        if let username = usernameTextField.text?.trimmedString() { //if username exists
            if !(username.isValidUsername) { //if not a valid username
                usernameTextField.hasError()
                values.errorCount += 1
                Service.presentAlert(on: self, title: "Invalid Username", message: "Username format is not valid. Please use characters, whitespace, and the following symbols . _ + - only")
            } else {
                values.username = username
                usernameTextField.hasNoError()
            }
        } else {
            usernameTextField.hasError(); values.errorCount += 1
            Service.presentAlert(on: self, title: "Invalid Username", message: "Field is empty")
        }
        print("THERE ARE \(values.errorCount) ERRORS")
        return values
    }
}

//MARK: Extensions
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImageView.contentMode = .scaleAspectFit
            userImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
