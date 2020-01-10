//
//  String+extensions.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

extension String {
    
    func emailEncryptedForFirebase() -> String { //string method that converts an email to a key that Firebase can accept. It first splits an email by "@", then convert "@" to a "_at_", and "_dot_" to a string
        let lastIndex = self.lastIndex(of: "@") //lastIndex because we want to search for @ from the end of the string //NOTE: make sure email being asked has @ symbol or it will crash
        let emailName = self.prefix(upTo: lastIndex!) //kobeBryant
        let emailDomain = self.suffix(from: lastIndex!) //@gmail.com
        let emailDomainWith_at_ = emailDomain.replacingOccurrences(of: "@", with: "_at_") //convert @ in emailDomain to _at_
        let newEmailDomain = emailDomainWith_at_.replacingOccurrences(of: ".", with: "_dot_") //conver all . in emailDomain to _dot_ //NOTE: must use this because email domain can have multiple "."
        return emailName + newEmailDomain
    }
    
    func emailDecryptedFromFirebase() -> String { //string method that converts an encrypted email back to original email
        let newEmail = self.replacingLastOccurrenceOfString("_at_", with: "@") //replace one occurence of _at_
        let lastIndex = newEmail.lastIndex(of: "@")
        let emailName = newEmail.prefix(upTo: lastIndex!)
        let emailDomain = newEmail.suffix(from: lastIndex!)
        let newEmailDomain = emailDomain.replacingOccurrences(of: "_dot_", with: ".") //NOTE: must use this because email domain can have multiple "."
        return emailName + newEmailDomain
    }
    
    func replacingLastOccurrenceOfString(_ searchString: String, with replacementString: String, caseInsensitive: Bool = true) -> String { //a string method that replace the last occurence of the searchString argument with replacementString argument. Used to convert _at_ back to @
        let options: String.CompareOptions
        if caseInsensitive { //search backwards, or search backwards and case sensitive
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        if let range = self.range(of: searchString,
                options: options,
                range: nil,
                locale: nil) { //get the range of index of the characters in the searchString
            return self.replacingCharacters(in: range, with: replacementString) //replace searchString's range with the replacementString argument
        }
        return self
    }
    
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" //\\. is escape character for dot
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

