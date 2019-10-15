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
    
    
    
    
    
//MARK: Properties
    var currentUser: String?
    
    
    
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentUser = User.currentUser()?.email {
            print("we have a user = \(currentUser)")
        } else {
            self.performSegue(withIdentifier: "toAuthVC", sender: nil)
        }
    }
    
    
    
    
//MARK: Methods
    
    
    
//MARK: Helpers
    
    
    
//MARK: IBActions
    
    
}

