//
//  String+extensions.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

extension String {
    
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidName: Bool {
        let regex = "[A-Za-z]*[ ]?[A-Za-z]*[.]?[ ]?[A-Za-z]{1,30}" //regex for full name //will take the following name formats, Samuel || Samuel P. || Samuel P. Folledo || Samuel Folledo
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self) //evaluate
    }
    
    var isValidUsername: Bool {
        let regex = "[A-Z0-9a-zâéè._+-]{1,15}" //regex for user name //accept any US characters, other characters, and symbols like (. _ + -)
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self) //evaluate
    }
    
    func trimmedString() -> String { //method that removes string's left and right white spaces and new lines
        let newWord: String = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return newWord
    }
}

