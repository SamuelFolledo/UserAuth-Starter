//
//  AuthenticationVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage

class AuthenticationVC: UIViewController {

//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var textMeButton: UIButton!
    
    @IBOutlet weak var emailSegmentedControl: UISegmentedControl!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var submitEmailButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var anonymousButton: UIButton!
    
    @IBOutlet weak var confirmPassView: UIView!
    @IBOutlet weak var emailAuthStackView: UIStackView!
    @IBOutlet weak var emailAuthStackView_Height: NSLayoutConstraint!
    
//MARK: Properties
    
        
        
        
        
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUp()
        
    }
    
    
    
    
//MARK: Methods
    func setUp() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        
        emailSegmentedControl.addTarget(self, action: #selector(handleSegmentedControlValueChanged(_:)), for: .valueChanged)
        confirmPassView.isHidden = true
        facebookButton.isHidden = false
        anonymousButton.isHidden = false
        
        codeTextField.isEnabled = false
        
    }
    
    private func login() {
        var errorCounter = 0
        let initialTime = Date()
        
        guard let email = emailTextField.text?.trimmedString() else {
            emailTextField.layer.borderColor = kREDCGCOLOR; return
        }
        guard let password = passwordTextField.text?.trimmedString() else {
            passwordTextField.layer.borderColor = kREDCGCOLOR; return
        }
        
        if !(email.isValidEmail) { //if email is not valid
            errorCounter += 1
            emailTextField.layer.borderColor = kREDCGCOLOR
            Service.presentAlert(on: self, title: "Invalid Email", message: "Email format is not valid. Please try again with another email")
        } else {
            emailTextField.layer.borderColor = kCLEARCGCOLOR
        }
        if password.count < 6 {
            errorCounter += 1
            passwordTextField.layer.borderColor = kREDCGCOLOR
            Service.presentAlert(on: self, title: "Password Count Error", message: "Password must be at least 6 characters")
            return
        } else {
            passwordTextField.layer.borderColor = kCLEARCGCOLOR
        }
        
        switch errorCounter {
        case 0:
            User.loginUserWith(email: email, password: password) { (error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Login Error", message: error.localizedDescription)
                    return
                } else {
                    self.getLengthOfSubmission(initialTime: initialTime)
                }
            }
        default:
            Service.presentAlert(on: self, title: "Error", message: "There are errors on the field. Please try again.")
            return
        }
    }
    
    private func register() {
        var errorCounter = 0
        let methodStart = Date()
        
        guard let email = emailTextField.text?.trimmedString() else {
            emailTextField.layer.borderColor = kREDCGCOLOR; return
        }
        if !(email.isValidEmail) { //if email is not valid
            emailTextField.layer.borderColor = kREDCGCOLOR
            errorCounter += 1
            Service.presentAlert(on: self, title: "Invalid Email Format", message: "Email format is not valid. Please try again with correct or another email")
        } else {
            emailTextField.layer.borderColor = kCLEARCGCOLOR
        }
        
        guard let password = passwordTextField.text?.trimmedString() else {
            passwordTextField.layer.borderColor = kREDCGCOLOR; return
        }
                
        if password.count < 6 {
            errorCounter += 1
            passwordTextField.layer.borderColor = kREDCGCOLOR
            Service.presentAlert(on: self, title: "Password Count Error", message: "Password must be at least 6 characters")
        } else {
            passwordTextField.layer.borderColor = kCLEARCGCOLOR
        }
        print("there are \(errorCounter) errors")
        
        switch errorCounter {
        case 0: //if 0 errorCounter... Register
            User.registerUserWith(email: email, password: password) { (error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
                } else { //if no error registering user...
                    
                    print("USER SUCCESSFULLY REGISTER \(User.currentUser())")
                    let uid = User.currentId()
                    
                }
            }
            
        default:
            Service.presentAlert(on: self, title: "Error", message: "There are errors on the field. Please try again.")
        }
    }
    
    
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any] ) {
        let usersReference = firDatabase.child(kUSERS).child(uid)
        usersReference.setValue(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
                return
            } else {
                let userValues:[String: Any] = [kFIRSTNAME: "", kLASTNAME: "", kAVATARURL: ""]
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
    @IBAction func textMeButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        switch emailSegmentedControl.selectedSegmentIndex {
        case 0: //if user is logging in
            login()
            guard let currentUser = User.currentUser() else { print("No user"); return }
            if currentUser.fullName == "" || currentUser.avatarURL == "" {
                self.performSegue(withIdentifier: "toNameVC", sender: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        case 1: //if user is registering
            register()
            self.performSegue(withIdentifier: "toNameVC", sender: nil)
        default:
            break
        }
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
            emailAuthStackView_Height.constant *= 0.66
            confirmPassView.alpha = 0
            submitEmailButton.setTitle("Login", for: .normal)
        case 1:
            confirmPassView.isHidden = false
            emailAuthStackView_Height.constant *= 1.33
            confirmPassView.alpha = 1
            submitEmailButton.setTitle("Register", for: .normal)
        default:
            break
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded() //Lays out the subviews immediately, if layout updates are pending.
        }
    }
    
    func getLengthOfSubmission(initialTime: Date) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let methodFinish = Date()
            let executionTime = methodFinish.timeIntervalSince(initialTime) //to get the executionTime
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            Service.alertWithActions(on: self, actions: [okAction], title: "Success!", message: "Successfully logged in \(executionTime) milliseconds")
        })
    }
    
}
