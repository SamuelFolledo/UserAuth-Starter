//
//  ProfileVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {


//MARK: IBOulets
       
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
        
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
    }
        
        

        
//MARK: IBActions
    @IBAction func submitButtonTapped(_ sender: Any) {
        popBack(2)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    func popBack(_ nb: Int) { //method that pops View controller to a certain amount nb
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
        

}
