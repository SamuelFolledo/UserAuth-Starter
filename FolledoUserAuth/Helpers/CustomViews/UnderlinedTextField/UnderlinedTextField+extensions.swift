//
//  UnderlinedTextField+extensions.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/15/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

extension UnderlinedTextField {
    //    @discardableResult
    func hasError() {
        self.setUnderlineColor(color: .systemRed)
    }
//    @discardableResult
    func hasNoError() {
        self.setDefaultUnderlineColor()
    }
}
