//
//  UserApple.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 1/21/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation
import CryptoKit //for hasing data for Apple Auth

//MARK: Apple Signin Helper
// Got from Firebase's Apple Signin Instructions: https://firebase.google.com/docs/auth/ios/apple?authuser=0
// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
func randomNonceString(length: Int = 32) -> String { //generates a random string to make sure the ID token you get was granted specifically in response to your app's authentication request TO PREVENT REPLAY ATTACKS
  precondition(length > 0)
  let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if length == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

@available(iOS 13, *)
func sha256(_ input: String) -> String { //for hashing input using CryptoKit's SHA256
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
    return hashString
}
