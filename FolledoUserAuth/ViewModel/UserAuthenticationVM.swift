//
//  UserAuthenticationVM.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 11/15/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

public final class UserAuthenticationViewModel {
    public let isEmailAuthentication: Bool
    
    public init(isEmailAuthentication: Bool) {
        self.isEmailAuthentication = isEmailAuthentication
    }
}
