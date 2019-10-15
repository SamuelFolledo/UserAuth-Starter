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
    }
    
    
    
    
//MARK: IBActions
    @IBAction func submitButtonTapped(_ sender: Any) {
        let inputValues: (errorCount: Int, firstName: String, lastName: String, username: String) = checkInputValues()
        switch inputValues.errorCount {
        case 0:

//            User.loginUserWith(email: inputValues.email, password: inputValues.password) { (error) in
//                if let error = error {
//                    Service.presentAlert(on: self, title: "Login Error", message: error.localizedDescription)
//                    return
//                } else { //if no errors
//                    //        User.updateCurrentUser(values: <#T##[String : Any]#>, withBlock: <#T##(String?) -> Void#>)
//                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//                }
//            }
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
