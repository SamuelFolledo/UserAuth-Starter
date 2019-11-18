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
            topTextField.isEmailTextField()
            bottomTextField.isPasswordTextField()
            continueButton.setTitle("Create Account/Login", for: .normal)
        } else { //setup phone Auth
            self.navigationItem.title =  "Phone Authentication"
            topLabel.text = "Phone Number"
            bottomLabel.text = "Code"
            bottomLabel.isHidden = true
            topTextField.isPhoneTextField()
            bottomTextField.isPhoneCodeTextField(isHidden: true)
            continueButton.setTitle("Text Password", for: .normal)
        }
    }    
    
//MARK: Private Methods
    fileprivate func login(email: String, password: String) {
        User.loginUserWith(email: email, password: password) { (error) in
            if let error = error {
                Service.presentAlert(on: self, title: "Login Error", message: error.localizedDescription)
                return
            } else {
                guard let currentUser = User.currentUser() else { print("No user"); return }
                self.goToNextController(user: currentUser)
            }
        }
    }
    
    fileprivate func register(email: String, password: String) {
//        let methodStart = Date()
        User.registerUserWith(email: email, password: password) { (error, user) in
            if let error = error {
                Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
            } else { //if no error registering user...
                let uid = User.currentId()
                let userValues:[String: Any] = [kUSERID: uid, kUSERNAME: "", kFIRSTNAME: "", kLASTNAME: "", kFULLNAME: "", kEMAIL: email, kAVATARURL: ""]
                self.registerUserIntoDatabaseWithUID(uid: uid, values: userValues)
            }
        }
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any] ) { //method that gets uid and a dictionary of values you want to give to users
        let usersReference = firDatabase.child(kUSERS).child(uid)
        usersReference.setValue(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                Service.presentAlert(on: self, title: "Register Error", message: error.localizedDescription)
                return
            } else { //if no error, save user
                saveEmailInDatabase(email:values[kEMAIL] as! String) //MARK: save to another table
                DispatchQueue.main.async {
                    let user = User(_dictionary: values)
                    saveUserLocally(user: user)
                    saveUserInBackground(user: user)
                    self.goToNextController(user: user)
                }
            }
        })
    }
    
//MARK: Helpers
    fileprivate func checkIfEmailExist(email:String, completion: @escaping (_ emailExist: Bool?) -> Void) { //check emails from kREGISTEREDUSERS and returns true if email exist in our Database
        let ref = firDatabase.queryEqual(toValue: email.emailEncryptedForFirebase(), childKey: kREGISTEREDUSERS)
        let emailRef = firDatabase.queryOrdered(byChild: kREGISTEREDUSERS).queryEqual(toValue: email.emailEncryptedForFirebase())
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print("snapshot = \(snapshot)")
                completion(true)
            } else {
                completion(false)
            }
        }, withCancel: nil)
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
        print("THERE ARE \(values.errorCount) ERRORS")
        return values
    }
    
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    
//MARK: IBActions
    @IBAction func continueButtonTapped(_ sender: Any) {
        if isEmailAuth { //email authentication
            let inputValues: (errorCount: Int, email: String, password: String) = checkInputValues()
            if inputValues.errorCount <= 0 { //if no error
                checkIfEmailExist(email: inputValues.email, completion: { (emailAlreadyExist) in //check if email exist in our Database, then login, else register
                    if let emailAlreadyExist = emailAlreadyExist {
                        emailAlreadyExist ? self.login(email: inputValues.email, password: inputValues.password) : self.register(email: inputValues.email, password: inputValues.password) //if emailExist, then login, else register
                    } else {
                        print("checkIfEmailExist emailAlreadyExist = nil")
                    }
                })
            } else { print("has \(inputValues.errorCount) textfields error") }
        } else { //phone authentication
            print("Phone Auth coming soon")
            goToFinishRegistration()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
