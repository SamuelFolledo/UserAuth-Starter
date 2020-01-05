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
    var userAuthViewModel: UserAuthenticationViewModel!
    
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
    }    
    
//MARK: Private Methods
    
//MARK: Helpers
    fileprivate func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        navigationItem.title = userAuthViewModel.navigationTitle
        userAuthViewModel.setupTopLabel(label: topLabel)
        userAuthViewModel.setupBottomLabel(label: bottomLabel)
        userAuthViewModel.setupErrorLabel(label: topErrorLabel)
        userAuthViewModel.setupErrorLabel(label: bottomErrorLabel)
        userAuthViewModel.setupTextFields(top: topTextField, bottom: bottomTextField)
        userAuthViewModel.setupContinueButton(button: continueButton)
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
            let vc:FinishRegistrationVC = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: kFINISHREGISTRATIONVC) as! FinishRegistrationVC
            nav?.pushViewController(vc, animated: false)
        }
    }
    
//    fileprivate func checkInputValues() -> (errorCount: Int, topFieldValue: String, bottomFieldValue: String) { //method that check for errors on input values from textfields, put a red border or clear border and return input values with errorCount //Note: work on PROPERLY HANDLING ERRORS in the future
//        var values: (errorCount: Int, topFieldValue: String, bottomFieldValue: String) = (0, "", "")
//        if let email = topTextField.text?.trimmedString() { //check if email exists
//            if !(email.isValidEmail) {
//                topTextField.hasError()
//                values.errorCount += 1
//                Service.presentAlert(on: self, title: "Invalid Email", message: "Email format is not valid")
//            } else {
//                values.topFieldValue = email
//                topTextField.hasNoError()
//            }
//        } else {
//            topTextField.hasError(); values.errorCount += 1
//            Service.presentAlert(on: self, title: "Invalid Email", message: "Email is empty")
//        }
//        if let password = bottomTextField.text?.trimmedString(){
//            if password.count < 6 {
//                bottomTextField.hasError(); values.errorCount += 1
//                Service.presentAlert(on: self, title: "Invalid Password", message: "Password must be at least 6 characters")
//            } else {
//                values.bottomFieldValue = password
//                bottomTextField.hasNoError()
//            }
//        } else {
//            bottomTextField.hasError(); values.errorCount += 1
//            Service.presentAlert(on: self, title: "Invalid Password", message: "Password is empty")
//        }
//        print("THERE ARE \(values.errorCount) ERRORS")
//        return values
//    }
    
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
//MARK: IBActions
    @IBAction func continueButtonTapped(_ sender: Any) {
        let inputValues: (topTF: UnderlinedTextField, bottomTF: UnderlinedTextField, errors: [String], topFieldValue: String, bottomFieldValue: String) = userAuthViewModel.checkInputValues(topTF: topTextField, bottomTF: bottomTextField)
        if inputValues.errors.count < 1 { //if no error
            userAuthViewModel.continueButtonTapped(topFieldValue: inputValues.topFieldValue, bottomFieldValue: inputValues.bottomFieldValue) { (error, user) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Error", message: error)
                } else {
                    print("User is \(userDictionaryFrom(user: user!))")
                    self.goToNextController(user: user!)
                }
            }
        } else { //handle error on the fields
            Service.presentAlert(on: self, title: "Error", message: "Error on the fields")
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
