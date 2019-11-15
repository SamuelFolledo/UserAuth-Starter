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
    
    
    
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    
//MARK: Methods
    private func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        topErrorLabel.isHidden = true
        topErrorLabel.textColor = .systemRed
        bottomErrorLabel.isHidden = true
        bottomErrorLabel.textColor = .systemRed
        topLabel.font = UIFont.boldSystemFont(ofSize: 16)
        bottomLabel.font = UIFont.boldSystemFont(ofSize: 16)
        continueButton.layer.cornerRadius = continueButton.frame.height / 10
        continueButton.clipsToBounds = true
    }
    
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    
//MARK: IBActions
    @IBAction func continueButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: kTONAMEVC, sender: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
