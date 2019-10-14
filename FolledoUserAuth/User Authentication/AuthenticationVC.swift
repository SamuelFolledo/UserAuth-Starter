//
//  AuthenticationVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class AuthenticationVC: UIViewController {

//MARK: IBOulets
    @IBOutlet weak var userImageView: UIImageView!
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
    
    

    
//MARK: IBActions
    @IBAction func textMeButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toNameVC", sender: nil)
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
    
}
