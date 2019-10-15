//
//  UITextField+extensions.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

extension UITextField {
//    @discardableResult
    func hasError() {
        self.layer.borderWidth = 1
        self.layer.borderColor = kREDCGCOLOR
    }
//    @discardableResult
    func hasNoError() {
        self.layer.borderWidth = 1
        self.layer.borderColor = kCLEARCGCOLOR
    }
}
