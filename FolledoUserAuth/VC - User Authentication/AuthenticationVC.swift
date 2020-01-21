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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObervers()
    }
    
//MARK: Private Methods
    fileprivate func setupKeyboardNotifications() { //setup notifications when keyboard shows or hide
        NotificationCenter.default.addObserver(self, selector: #selector(AuthenticationVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AuthenticationVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func removeKeyboardObervers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
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
    
    fileprivate func continueTapped() {
        let inputValues: (topTF: UnderlinedTextField, bottomTF: UnderlinedTextField, errors: [String], topFieldValue: String, bottomFieldValue: String) = userAuthViewModel.checkInputValues(topTF: topTextField, bottomTF: bottomTextField) //analyze text fields inputs
        topTextField = inputValues.topTF
        bottomTextField = inputValues.bottomTF
        if inputValues.errors.count == 0 { //if no error
            userAuthViewModel.continueButtonTapped(topFieldValue: inputValues.topFieldValue, bottomFieldValue: inputValues.bottomFieldValue) { (user, error) in //get our user, or error
                if let error = error {
                    Service.presentAlert(on: self, title: "Authentication Error", message: error)
                    return
                } else if let user = user { //if have user from email or phone auth
                    print("Go to next controller with \(user.fullName)")
                    goToNextController(vc: self, user: user)
                    return
                } else { //error nil and user nil; after texting phone auth code
                    print("Sending code...")
                    self.userAuthViewModel.setupContinueButton(button: self.continueButton)
                    self.bottomLabel.isHidden = false
                    self.bottomTextField.isHidden = false
                    return
                }
            }
        } else { //handle error on the fields
            let errorMessage: String = inputValues.errors.joined(separator: ", ") //all errors with comma in between
            Service.presentAlert(on: self, title: "Fields Error", message: errorMessage)
            return
        }
    }
    
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) { //makes the view go up by keyboard's height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardSize.height / 1.25
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) { //put the view back to 0
        //if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        if view.frame.origin.y != 0 {
            //view.frame.origin.y += keyboardSize.height
            view.frame.origin.y = 0
        }
        //}
    }
    
//MARK: IBActions
    @IBAction func continueButtonTapped(_ sender: Any) {
        continueTapped()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
