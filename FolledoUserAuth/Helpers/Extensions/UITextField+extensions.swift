//
//  UITextField+extensions.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

extension UITextField {
    func isPassWordLabel() {
        self.text = "Password"
        self.isHidden = false
    }
    
    func isEmailTextField() {
        self.keyboardType = .emailAddress
    }
    
    func isPasswordTextField() {
        self.isHidden = false
        self.isSecureTextEntry = true
        self.keyboardType = .default
        self.text = "pogi99" //MARK: Remove on production
    }
    
    func isPhoneTextField() {
        self.keyboardType = .phonePad
    }
    
    func isPhoneCodeTextField(isHidden: Bool) {
        self.keyboardType = .numberPad
        self.isSecureTextEntry = false
        if isHidden {
            self.isHidden = true
        } else {
            self.isHidden = true
        }
    }
    
//    @discardableResult
//    func hasError() {
//        self.layer.borderWidth = 1
//        self.layer.borderColor = kREDCGCOLOR
//    }
////    @discardableResult
//    func hasNoError() {
//        self.layer.borderWidth = 1
//        self.layer.borderColor = kCLEARCGCOLOR
//    }
}
