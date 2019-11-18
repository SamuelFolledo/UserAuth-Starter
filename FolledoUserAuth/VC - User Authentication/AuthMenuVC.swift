//
//  AuthMenuVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage

class AuthMenuVC: UIViewController {

//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var anonymousButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
//MARK: Properties
        
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUp()
    }
    
    
    
    
//MARK: Methods
    func setUp() {
        
    }
    
//MARK: IBActions
    @IBAction func emailButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: true)
    }
    @IBAction func phoneButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: false)
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Google is still under production. Check back at a later time")
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Facebook is still under production. Check back at a later time")
    }
    
    @IBAction func anonymousButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Anonymous is still under production. Check back at a later time")
    }
    
//MARK: Helpers
   
}
