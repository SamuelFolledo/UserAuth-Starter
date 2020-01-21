//
//  UserAuthenticationVM.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/15/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseAuth

public final class UserAuthenticationViewModel {
    public let isEmailAuthentication: Bool
    public let navigationTitle: String
    public let topLabelText: String
    public var topErrorLabelText: String
    public let bottomLabelText: String
    public var bottomErrorLabelText: String
    public var continueButtonTitle: String
    public var hasPhoneCode: Bool = false
    
    public init(isEmailAuthentication: Bool) {
        self.isEmailAuthentication = isEmailAuthentication
        topErrorLabelText = ""
        bottomErrorLabelText = ""
        if isEmailAuthentication {
            navigationTitle = "Email Authentication"
            topLabelText = "Email"
            bottomLabelText = "Password"
            continueButtonTitle = "Create Account/Login"
        } else {
            navigationTitle = "Phone Authentication"
            topLabelText = "Phone Number"
            bottomLabelText = "Code"
            continueButtonTitle = "Text Password"
        }
    }
    
    public func setupTopLabel(label: UILabel) {
        label.isAuthLabel()
        label.text = isEmailAuthentication ? "Email" : "Phone Number"
    }
    
    public func setupBottomLabel(label: UILabel) {
        label.isAuthLabel()
        if isEmailAuthentication {
            label.text = "Password"
            label.isHidden = false
        } else {
            label.text = "Code"
            label.isHidden = true
        }
    }
    
    public func setupErrorLabel(label: UILabel, isHidden: Bool = true) {
        label.isAuthErrorLabel()
        label.text = ""
        label.textColor = .red
        label.isHidden = isHidden
    }
    
    func setupTextFields(top topTF: UnderlinedTextField, bottom bottomTF: UnderlinedTextField, hideBottom hasPhoneCode: Bool = false) {
        if isEmailAuthentication {
            topTF.isEmailTextField()
            bottomTF.isPasswordTextField()
        } else {
            topTF.isPhoneTextField()
            bottomTF.isPhoneCodeTextField(isHidden: !hasPhoneCode) //if hasPhoneCode, then hide == opposite of hasPhoneCode
        }
    }
    
    public func setupContinueButton(button: UIButton) {
        button.isAuthButton()
        button.setTitle(self.continueButtonTitle, for: .normal)
    }
    
    func continueButtonTapped(topFieldValue: String, bottomFieldValue: String, completion: @escaping (_ user: User?, _ error: String?) -> Void) {
        if isEmailAuthentication {
            continueWithEmail(email: topFieldValue, password: bottomFieldValue) { (error, user) in
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(user, nil)
                }
            }
        } else { //phone authentication
            if !self.hasPhoneCode { //text code if no phone code yet
                self.textPhoneCode(phoneNumber: topFieldValue) { (error) in
                    if let error = error {
                        completion(nil, error)
                    }
                    self.hasPhoneCode = true
                    self.continueButtonTitle = "Continue with Phone"
                    completion(nil, nil)
                }
            } else if self.hasPhoneCode && bottomFieldValue != "" { //if we have phone code and it is not empty, register or login phone
                self.continueWithPhone(phone: topFieldValue, code: bottomFieldValue) { (user, error) in
                    if let error = error {
                        completion(nil, error)
                    }
                    completion(user, nil)
                }
            } else {
                completion(nil, "Field is empty")
            }
        }
    }
    
    fileprivate func continueWithEmail(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) { //if no error
        checkIfEmailExist(email: email, completion: { (emailAlreadyExist) in //check if email exist in our Database, then login, else register
            if let emailAlreadyExist = emailAlreadyExist {
                if emailAlreadyExist { //LOGIN
                    self.loginWithEmail(email: email, password: password) { (error, user) in
                        if let error = error {
                            completion(error, nil)
                        } else {
                            completion(nil, user)
                        }
                    }
                } else { //Register because email does not exist
                    self.registerWithEmail(email: email, password: password) { (error, user) in
                        if let error = error {
                            completion(error, nil)
                        } else {
                            completion(nil, user)
                        }
                    }
                }
            } else {
                print("checkIfEmailExist emailAlreadyExist = nil")
                completion("Weird email bug", nil)
            }
        })
    }
    
//MARK: Helpers
    fileprivate func checkIfEmailExist(email:String, completion: @escaping (_ emailExist: Bool?) -> Void) { //check emails from kREGISTEREDUSERS and returns true if email exist in our Database
        let emailRef = firDatabase.child(kREGISTEREDUSERS).queryOrdered(byChild: kEMAIL).queryEqual(toValue: email)
        emailRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                print("snapshot = \(snapshot)")
                completion(true)
            } else {
                completion(false)
            }
        }, withCancel: nil)
    }
    
    fileprivate func loginWithEmail(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) {
        User.loginUserWith(email: email, password: password) { (error) in
            if let error = error {
                completion(error.localizedDescription, nil)
            } else {
                guard let currentUser = User.currentUser() else { print("No user"); return }
                completion(nil, currentUser)
            }
        }
    }
    
    fileprivate func registerWithEmail(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) {
        User.registerUserWith(email: email, password: password) { (error, user) in
            if let error = error {
                completion(error, nil)
            } else { //if no error registering user...
                completion(nil, user)
            }
        }
    }
    
    func checkInputValues(topTF: UnderlinedTextField, bottomTF: UnderlinedTextField) -> (topTF: UnderlinedTextField, bottomTF: UnderlinedTextField, errors: [String], topFieldValue: String, bottomFieldValue: String) { //method that check for errors on input values from textfields, put a red border or clear border and return input values with errorCount //Note: work on PROPERLY HANDLING ERRORS in the future
        var values: (topTF: UnderlinedTextField, bottomTF: UnderlinedTextField, errors: [String], topFieldValue: String, bottomFieldValue: String) = (topTF: topTF, bottomTF: bottomTF, errors: [], topFieldValue: "", bottomFieldValue: "")
        guard let topText: String = topTF.text?.trimmedString(), topText != "" else { //unwrap top's value
            values.topTF.hasError()
            values.errors.append("Field is empty")
            return values
        }
        if isEmailAuthentication { //AUTHENTICATION = EMAIL
            if !(topText.isValidEmail) { //if email is not valid...
                values.topTF.hasError()
                values.errors.append("Email format is not valid")
            } else {
                values.topFieldValue = topText
                values.topTF.hasNoError()
            }
            guard let bottomText = topTF.text?.trimmedString(), bottomText != "" else { //if password is empty...
                values.bottomTF.hasError()
                values.errors.append("Field is empty")
                return values
            }
            if bottomText.count < 6 { //if password is invalid...
                values.bottomTF.hasError()
                values.errors.append("Password must be at least 6 characters")
            } else {
                values.bottomFieldValue = bottomText
                values.bottomTF.hasNoError()
            }
        } else { //AUTHENTICATION = PHONE
            if topText.prefix(1) != "+" { //if first character is not "+"
                topTF.hasError()
                values.errors.append("Phone number must start with + and country code")
            } else {
                values.topFieldValue = topText
            }
            if values.errors.count == 0 { //if no error, text a code or authenticate
                if !hasPhoneCode { //text for code
                    print("Texting code...")
                } else { //check bottom text
                    guard let bottomText = bottomTF.text?.trimmedString(), bottomText != "" else { //if password is empty...
                        values.bottomTF.hasError()
                        values.errors.append("Field is empty")
                        return values
                    }
                    values.bottomFieldValue = bottomText
                }
            }
        }
        print("THERE ARE \(values.errors.count) ERRORS")
        return values
    }
    
//MARK: Phone Auth
    private func textPhoneCode(phoneNumber: String, completion: @escaping ( _ error: String?) -> Void) { //method that sends a text a code to a phone number
        let phoneAuth = PhoneAuthProvider.provider()
        phoneAuth.verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                completion(error.localizedDescription)
            }
            UserDefaults.standard.set(verificationId!, forKey: kVERIFICATIONCODE)
            UserDefaults.standard.synchronize()
            completion(nil)
        }
    }
    
    private func continueWithPhone(phone: String, code: String, completion: @escaping (_ user: User?, _ error: String?) -> Void) { //method once the user has inputted phone number and verification code
        let verificationID = UserDefaults.standard.value(forKey: kVERIFICATIONCODE) //when user inputs phone number and request a code, firebase will send the modification code which is not the password code. This code is sent by Firebase in the background to identify if the application is actually running on the device that is requesting the code.
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID as! String, verificationCode: code) //get our credential
        User.authenticateUser(credential: credential, userDetails: [kPHONENUMBER: phone]) { (user, error) in //authenticate and get user
            if let error = error {
                completion(nil, error)
                return
            }
            UserDefaults.standard.removeObject(forKey: kVERIFICATIONCODE)
            UserDefaults.standard.synchronize() //remove code
            completion(user, nil)
        }
    }
}
