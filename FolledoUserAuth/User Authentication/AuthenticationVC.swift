//
//  AuthenticationVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class AuthenticationVC: UIViewController {
//MARK: Properties
    var isEmailAuth: Bool!
    
//MARK: IBOulets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topTextField: UnderlinedTextField!
    @IBOutlet weak var topErrorLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomTextField: UnderlinedTextField!
    @IBOutlet weak var bottomErrorLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEmailAuth { //setup email auth
            self.navigationItem.title = "Email Authentication"
            topLabel.text = "Email"
            bottomLabel.text = "Password"
            bottomLabel.isHidden = false
            topTextField.keyboardType = .emailAddress
            bottomTextField.isHidden = false
            bottomTextField.isSecureTextEntry = true
            bottomTextField.keyboardType = .default
            bottomTextField.text = "pogi99" //MARK: Remove on production
            continueButton.setTitle("Create Account/Login", for: .normal)
        } else { //setup phone Auth
            self.navigationItem.title =  "Phone Authentication"
            topLabel.text = "Phone Number"
            bottomLabel.text = "Code"
            bottomLabel.isHidden = true
            topTextField.keyboardType = .phonePad
            bottomTextField.isHidden = true
            bottomTextField.isSecureTextEntry = false
            bottomTextField.keyboardType = .numberPad
            continueButton.setTitle("Text Password", for: .normal)
        }
    }    
    
//MARK: Private Methods
    fileprivate func login() {
        let inputValues: (errorCount: Int, email: String, password: String) = checkInputValues()
        switch inputValues.errorCount {
        case 0:
            User.loginUserWith(email: inputValues.email, password: inputValues.password) { (error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Login Error", message: error.localizedDescription)
                    return
                } else {
                    guard let currentUser = User.currentUser() else { print("No user"); return }
                    if currentUser.fullName == "" || currentUser.avatarURL == "" {
                        self.performSegue(withIdentifier: kTONAMEVC, sender: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        default:
            Service.presentAlert(on: self, title: "Error", message: "There are errors on the field. Please try again.")
            return
        }
    }
    
    fileprivate func register() {
        let inputValues: (errorCount: Int, email: String, password: String) = checkInputValues()
//        let methodStart = Date()
        switch inputValues.errorCount {
        case 0: //if 0 errorCounter... Register
            User.registerUserWith(email: inputValues.email, password: inputValues.password) { (error, user) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
                } else { //if no error registering user...
                    let uid = User.currentId()
                    let userValues:[String: Any] = [kUSERID: uid, kUSERNAME: "", kFIRSTNAME: "", kLASTNAME: "", kFULLNAME: "", kEMAIL: inputValues.email, kAVATARURL: ""]
                    self.registerUserIntoDatabaseWithUID(uid: uid, values: userValues)
                }
            }
        default:
            Service.presentAlert(on: self, title: "Error", message: "There are errors on the field. Please try again.")
        }
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any] ) { //method that gets uid and a dictionary of values you want to give to users
        let usersReference = firDatabase.child(kUSERS).child(uid)
        usersReference.setValue(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
                return
            } else { //if no error, save user
                DispatchQueue.main.async {
                    let user = User(_dictionary: values)
                    saveUserLocally(user: user)
                    saveUserInBackground(user: user)
                    self.goToNextController(user: user)
                }
            }
        })
    }
    
    fileprivate func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        topErrorLabel.isAuthErrorLabel()
        bottomErrorLabel.isAuthErrorLabel()
        topLabel.isAuthLabel()
        bottomLabel.isAuthLabel()
        continueButton.isAuthButton()
    }
    
    
//MARK: Helpers
    fileprivate func goToNextController(user: User) {
        if user.firstName == "" || user.avatarURL == "" {
            let nav = self.navigationController //grab an instance of the current navigationController
            DispatchQueue.main.async { //make sure all UI updates are on the main thread.
                nav?.view.layer.add(CATransition().segueFromRight(), forKey: nil)
                let vc:FinishRegistrationVC = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: kFINISHREGISTRATIONVC) as! FinishRegistrationVC //.instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
                vc.user = user
                nav?.pushViewController(vc, animated: false)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func goToFinishRegistration() {
        let nav = self.navigationController //grab an instance of the current navigationController
        DispatchQueue.main.async { //make sure all UI updates are on the main thread.
            nav?.view.layer.add(CATransition().segueFromRight(), forKey: nil)
            let vc:FinishRegistrationVC = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: kFINISHREGISTRATIONVC) as! FinishRegistrationVC //.instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            nav?.pushViewController(vc, animated: false)
        }
    }
    
    fileprivate func checkInputValues() -> (errorCount: Int, email: String, password: String) { //method that check for errors on input values from textfields, put a red border or clear border and return input values with errorCount
        var values: (errorCount: Int, email: String, password: String) = (0, "", "")
        if let email = topTextField.text?.trimmedString() { //check if email exists
            if !(email.isValidEmail) {
                topTextField.hasError()
                values.errorCount += 1
                Service.presentAlert(on: self, title: "Invalid Email", message: "Email format is not valid")
            } else {
                values.email = email
                topTextField.hasNoError()
            }
        } else {
            topTextField.hasError(); values.errorCount += 1
            Service.presentAlert(on: self, title: "Invalid Email", message: "Email is empty")
        }
        if let password = bottomTextField.text?.trimmedString(){
            if password.count < 6 {
                bottomTextField.hasError(); values.errorCount += 1
                Service.presentAlert(on: self, title: "Invalid Password", message: "Password must be at least 6 characters")
            } else {
                values.password = password
                bottomTextField.hasNoError()
            }
        } else {
            bottomTextField.hasError(); values.errorCount += 1
            Service.presentAlert(on: self, title: "Invalid Password", message: "Password is empty")
        }
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
        print("THERE ARE \(values.errorCount) ERRORS")
        return values
    }
    
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    
//MARK: IBActions
    @IBAction func continueButtonTapped(_ sender: Any) {
//        self.performSegue(withIdentifier: kTONAMEVC, sender: nil)
        if isEmailAuth {
            register()
        } else {
            print("Phone Auth coming soon")
            goToFinishRegistration()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
