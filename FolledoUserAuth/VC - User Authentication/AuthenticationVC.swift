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
        if user.firstName == "" || user.imageUrl == "" {
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
    
    fileprivate func continueTapped() {
        let inputValues: (topTF: UnderlinedTextField, bottomTF: UnderlinedTextField, errors: [String], topFieldValue: String, bottomFieldValue: String) = userAuthViewModel.checkInputValues(topTF: topTextField, bottomTF: bottomTextField)
        topTextField = inputValues.topTF
        bottomTextField = inputValues.bottomTF
        if inputValues.errors.count == 0 { //if no error
            userAuthViewModel.continueButtonTapped(topFieldValue: inputValues.topFieldValue, bottomFieldValue: inputValues.bottomFieldValue) { (error, user) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Authentication Error", message: error)
                } else {
                    if !self.userAuthViewModel.isEmailAuthentication && self.userAuthViewModel.hasPhoneCode == true { //if we are in phone auth and we have not received a phone code, then do not continue as user is still nil
                        print("Sending code...")
                        self.userAuthViewModel.setupContinueButton(button: self.continueButton)
                        self.bottomLabel.isHidden = false
                        self.bottomTextField.isHidden = false
                    } else { //
                        print("Go to next controller")
                        guard let user: User = user else { return }
                        self.goToNextController(user: user)
                    }
                }
            }
        } else { //handle error on the fields
            let errorMessage: String = inputValues.errors.joined(separator: ", ") //all errors with comma in between
            Service.presentAlert(on: self, title: "Fields Error", message: errorMessage)
        }
    }
    
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
//MARK: IBActions
    @IBAction func continueButtonTapped(_ sender: Any) {
        continueTapped()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
