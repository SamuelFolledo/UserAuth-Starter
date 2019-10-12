//
//  LoginView.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class LoginView: UIView {

    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.clearButtonMode = .unlessEditing
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let password: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .default
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .unlessEditing
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let submitButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Login", for: .normal)
        return btn
    }()
    
    let facebookButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Signin with Facebook", for: .normal)
        return btn
    }()
    
    let anonymousButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Signin Anonymously", for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        setupView()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func setupView() {
        
    }

}
