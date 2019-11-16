//
//  AuthenticationVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class AuthenticationVC: UIViewController {

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
    
    
//MARK: Properties
    var isEmailAuth: Bool!
    
    
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEmailAuth { //setup email auth
            self.navigationItem.title = "Authenticate with Email"
            topLabel.text = "Email"
            bottomLabel.text = "Password"
            bottomLabel.isHidden = false
            bottomTextField.isHidden = false
            continueButton.setTitle("Create Account/Login", for: .normal)
        } else { //setup phone Auth
            self.navigationItem.title =  "Authenticate with Phone"
            topLabel.text = "Phone Number"
            bottomLabel.text = "Code"
            bottomLabel.isHidden = true
            bottomTextField.isHidden = true
            continueButton.setTitle("Text Password", for: .normal)
        }
    }    
    
//MARK: Methods
    private func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        topErrorLabel.isAuthErrorLabel()
        bottomErrorLabel.isAuthErrorLabel()
        topLabel.isAuthLabel()
        bottomLabel.isAuthLabel()
        continueButton.isAuthButton()
    }
    
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    
//MARK: IBActions
    @IBAction func continueButtonTapped(_ sender: Any) {
//        self.performSegue(withIdentifier: kTONAMEVC, sender: nil)
        let nav = self.navigationController //grab an instance of the current navigationController
        DispatchQueue.main.async { //make sure all UI updates are on the main thread.
            nav?.view.layer.add(CATransition().segueFromRight(), forKey: nil)
            let vc:UIViewController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: kFINISHREGISTRATIONVC) as UIViewController //.instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            nav?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
