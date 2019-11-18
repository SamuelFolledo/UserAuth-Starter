//
//  AuthMenuVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage

class AuthMenuVC: UIViewController {

//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
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
        
    }
    
//MARK: IBActions
    @IBAction func emailButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: false)
    }
    @IBAction func phoneButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: false)
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: true)
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func anonymousButtonTapped(_ sender: Any) {
        
    }
    
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    @objc fileprivate func handleSegmentedControlValueChanged(_ sender: UISegmentedControl) { //method that will update email views for login and register
        switch sender.selectedSegmentIndex {
        case 0: //login
            confirmPassView.isHidden = true
            confirmPassView.alpha = 0
            submitEmailButton.setTitle("Login", for: .normal)
        case 1:
            confirmPassView.isHidden = false
            confirmPassView.alpha = 1
            submitEmailButton.setTitle("Register", for: .normal)
        default:
            break
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded() //Lays out the subviews immediately, if layout updates are pending.
        }
    }
    
    func getLengthOfSubmission(initialTime: Date) { //present an alert controller that displays the time spent to finish execution since initial time
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let methodFinish = Date()
            let executionTime = methodFinish.timeIntervalSince(initialTime) //to get the executionTime
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            Service.alertWithActions(on: self, actions: [okAction], title: "Success!", message: "Successfully logged in \(executionTime) milliseconds")
        })
    }
    
//    fileprivate func checkInputValues() -> (errorCount: Int, email: String, password: String) { //method that check for errors on input values from textfields, put a red border or clear border and return input values with errorCount
//        var values: (errorCount: Int, email: String, password: String) = (0, "", "")
//        if let email = emailTextField.text?.trimmedString() { //check if email exists
//            if !(email.isValidEmail) {
//                emailTextField.hasError()
//                values.errorCount += 1
//                Service.presentAlert(on: self, title: "Invalid Email", message: "Email format is not valid")
//            } else {
//                values.email = email
//                emailTextField.hasNoError()
//            }
//        } else {
//            emailTextField.hasError(); values.errorCount += 1
//            Service.presentAlert(on: self, title: "Invalid Email", message: "Email is empty")
//        }
//        if let password = passwordTextField.text?.trimmedString(){
//            if password.count < 6 {
//                passwordTextField.hasError(); values.errorCount += 1
//                Service.presentAlert(on: self, title: "Invalid Password", message: "Password must be at least 6 characters")
//            } else {
//                values.password = password
//                passwordTextField.hasNoError()
//            }
//        } else {
//            passwordTextField.hasError(); values.errorCount += 1
//            Service.presentAlert(on: self, title: "Invalid Password", message: "Password is empty")
//        }
//        if emailSegmentedControl.selectedSegmentIndex == 1 { //if we are registering, also check confirm password field
//            if let confirmPass = confirmPasswordTextField.text?.trimmedString(){
//                if confirmPass.count < 6 {
//                    confirmPasswordTextField.hasError(); values.errorCount += 1
//                } else {
//                    if confirmPass == passwordTextField.text?.trimmedString() {
//                        values.password = confirmPass
//                        confirmPasswordTextField.hasNoError()
//                    } else {
//                        confirmPasswordTextField.hasError()
//                        passwordTextField.hasError()
//                        values.errorCount += 1
//                        Service.presentAlert(on: self, title: "Invalid Password", message: "Passwords did not match")
//                    }
//                }
//            } else {
//                confirmPasswordTextField.hasError(); values.errorCount += 1
//            }
//        }
//        print("THERE ARE \(values.errorCount) ERRORS")
//        return values
//    }
}
