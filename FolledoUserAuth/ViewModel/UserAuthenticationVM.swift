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
}
