//
//  ViewController.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//MARK: IBOulets
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    
    
    
//MARK: Properties
    
    
    
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let firstName = User.currentUser()?.firstName {
            if firstName != "" {
                profileButton.title = firstName
            } else { self.performSegue(withIdentifier: kTOAUTHMENUVC, sender: nil) }
        } else {
            self.performSegue(withIdentifier: kTOAUTHMENUVC, sender: nil)
        }
    }
    
    
    
    
//MARK: Methods
    
    
    
//MARK: Helpers
    
    
    
//MARK: IBActions
    @IBAction func profileButtonTapped(_ sender: Any) {
        
    }
    
}

