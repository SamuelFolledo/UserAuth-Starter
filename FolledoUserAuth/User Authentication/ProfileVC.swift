//
//  ProfileVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
//MARK: Properties
    
    
    
//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    
    
        
        
//MARK: Methods
    func setUp() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        userImageView.isUserInteractionEnabled = true
    }
    
    
    
    
//MARK: IBActions
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) { //delete user if they went back
        User.deleteUser(completion: { (error) in
            if let error = error {
                Service.presentAlert(on: self, title: "Error Deleting User", message: error.localizedDescription)
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
    
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    

}
