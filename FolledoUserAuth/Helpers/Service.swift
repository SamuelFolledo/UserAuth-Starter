//
//  Service.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

class Service {
    static func toAuthenticationVC(fromVC: UIViewController, isEmailAuth:Bool) {
        guard let nav = fromVC.navigationController else { return } //grab an instance of the current navigationController
        DispatchQueue.main.async { //make sure all UI updates are on the main thread.
            nav.view.layer.add(CATransition().segueFromRight(), forKey: nil) //show from right to left CATransition
            let vc:AuthenticationVC = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: kAUTHENTICATIONVC) as! AuthenticationVC //.instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            vc.userAuthViewModel = UserAuthenticationViewModel(isEmailAuthentication: isEmailAuth) //assign the view model
            nav.pushViewController(vc, animated: false)
        }
    }
    
    func popBack(on: UIViewController, nb: Int) { //method that pops View controller to a certain amount nb
        if let viewControllers: [UIViewController] = on.navigationController?.viewControllers {
            guard viewControllers.count < nb else {
            on.navigationController?.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
                return
            }
        }
    }
    
    //presentAlert
    static func presentAlert(on: UIViewController, title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(okAction)
        on.present(alertVC, animated: true, completion: nil)
    }
    
    static func alertWithActions(on: UIViewController, actions: [UIAlertAction], title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertVC.addAction(action)
        }
        on.present(alertVC, animated: true, completion: nil)
    }
    
    static func toMenuController(on: UIViewController) {
        goToController(on: on, withIdentifier: kMENUCONTROLLER)
    }
    static func toChatController(on: UIViewController) {
        goToController(on: on, withIdentifier: kCHATCONTROLLER)
    }
    static func toLoginController(on: UIViewController) {
        goToController(on: on, withIdentifier: kLOGINCONTROLLER)
    }
    static func toAnimationController(on: UIViewController) {
        goToController(on: on, withIdentifier: kANIMATIONCONTROLLER)
    }
    
    static func goToController(on: UIViewController, withIdentifier identifier: String) {
        let vc: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        on.present(vc, animated: true, completion: nil)
    }
    
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    static func isValidEmail(email: String) -> Bool {
        let reg = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        
        let test = NSPredicate(format: "SELF MATCHES %@", reg)
        let result = test.evaluate(with: email)
        
        return result
    }
    
}
