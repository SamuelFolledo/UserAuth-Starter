//
//  UIButton+extensions.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/15/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

extension UIButton {
    func isAuthButton() {
        self.layer.cornerRadius = self.frame.height / 10
        self.clipsToBounds = true
    }
}
