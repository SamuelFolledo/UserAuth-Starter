//
//  UserAuthenticationVM.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/15/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

public final class UserAuthenticationViewModel {
    public let isEmailAuthentication: Bool
    
    public let navigationTitle: String
    public let topLabelText: String
    public var topErrorLabelText: String
    public let bottomLabelText: String
    public var bottomErrorLabelText: String
    public var continueButtonTitle: String
    
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
    
    func continueButtonTapped(topFieldValue: String, bottomFieldValue: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) {
        if isEmailAuthentication {
            continueWithEmail(email: topFieldValue, password: bottomFieldValue) { (error, user) in
                if let error = error {
                    completion(error, nil)
                } else {
                    completion(nil, user)
                }
            }
        } else {
            continueWithPhone(phone: topFieldValue, code: bottomFieldValue) { (error, user) in
                if let error = error {
                    completion(error, nil)
                } else {
                    completion(nil, user)
                }
            }
        }
    }
    
    fileprivate func continueWithEmail(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) { //if no error
        checkIfEmailExist(email: email, completion: { (emailAlreadyExist) in //check if email exist in our Database, then login, else register
            if let emailAlreadyExist = emailAlreadyExist {
                if emailAlreadyExist { //LOGIN
                    self.login(email: email, password: password) { (error, user) in
                        if let error = error {
                            completion(error, nil)
                        } else {
                            completion(nil, user)
                        }
                    }
                } else { //Register because email does not exist
                    self.register(email: email, password: password) { (error, user) in
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
    
    fileprivate func login(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) {
        User.loginUserWith(email: email, password: password) { (error) in
            if let error = error {
                completion(error.localizedDescription, nil)
            } else {
                guard let currentUser = User.currentUser() else { print("No user"); return }
                completion(nil, currentUser)
            }
        }
    }
    
    fileprivate func register(email: String, password: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) {
        //        let methodStart = Date()
        User.registerUserWith(email: email, password: password) { (error, user) in
            if let error = error {
                completion(error.localizedDescription, nil)
            } else { //if no error registering user...
                let uid = User.currentId()
                let userValues:[String: Any] = [kUSERID: uid, kUSERNAME: "", kFIRSTNAME: "", kLASTNAME: "", kFULLNAME: "", kEMAIL: email, kAVATARURL: ""]
                self.registerUserIntoDatabaseWithUID(uid: uid, values: userValues) { (error, user) in
                    if let error = error {
                        completion(error, nil)
                    } else {
                        completion(nil, user)
                    }
                }
            }
        }
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any], completion: @escaping (_ error: String?, _ user: User?) -> Void) { //method that gets uid and a dictionary of values you want to give to users
        let usersReference = firDatabase.child(kUSERS).child(uid)
        usersReference.setValue(values, withCompletionBlock: { (error, ref) in
            if let error = error {
                completion(error.localizedDescription, nil)
            } else { //if no error, save user
                saveEmailInDatabase(email:values[kEMAIL] as! String) //MARK: save to another table
                DispatchQueue.main.async {
                    let user = User(_dictionary: values)
                    saveUserLocally(user: user)
                    saveUserInBackground(user: user)
                    completion(nil, user)
                }
            }
        })
    }
    
    
//MARK: Phone Auth
    private func continueWithPhone(phone: String, code: String, completion: @escaping (_ error: String?, _ user: User?) -> Void) {
        
        
        
        print("Phone Auth is unfinish")
        completion("Phone Auth is unfinish", nil)
    }
}
