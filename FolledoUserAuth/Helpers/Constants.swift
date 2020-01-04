//
//  Constants.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

public let firDatabase = Database.database().reference()
public let kVERIFICATIONCODE = "firebase_verification" //for phone auth

//ids and keys for one signal
public let kONESIGNALAPPID: String = "586d3ef3-6411-41d0-ab81-2a797a16a50b"
public let kONESIGNALID: String = "OneSignalId"
public let kUSERID: String = "userID"
public let kUSERNAME: String = "username"
public let kFIRSTNAME: String = "firstName"
public let kLASTNAME: String = "lastName"
public let kFULLNAME: String = "fullName"
public let kEMAIL: String = "email"
public let kAVATARURL: String = "avatarURL"
public let kCURRENTUSER: String = "currentUser" //for userDefaults
public let kUSERS: String = "user" //for firebase
public let kMESSAGES: String = "message"
public let kPUSHID: String = "pushId"

//MARK: Other Constants
public let kCREATEDAT: String = "createdAt"
public let kUPDATEDAT: String = "updatedAt"
public let kGAMESESSIONS: String = "gameSessions"
public let kUSERTOGAMESESSIONS: String = "user-gameSessions"
public let kPLAYER1ID: String = "player1Id"
public let kPLAYER2ID: String = "player2Id"
public let kPLAYER1NAME: String = "player1Name"
public let kPLAYER2NAME: String = "player2Name"
public let kPLAYER1EMAIL: String = "player1Email"
public let kPLAYER2EMAIL: String = "player2Email"
public let kPLAYER1AVATARURL: String = "player1AvatarUrl"
public let kPLAYER2AVATARURL: String = "player2AvatarUrl"
public let kPLAYER1IMAGE: String = "player1Image"
public let kPLAYER2IMAGE: String = "player2Image"
public let kPLAYER1HP: String = "player1Hp"
public let kPLAYER2HP: String = "player2Hp"
public let kP1MOVE: String = "p1Move"
public let kP2MOVE: String = "p2Move"

public let kWINNERUID: String = "winnerUid"
public let kCURRENTGAME: String = "currentGame"
public let kGAMEATTACK: String = "gameAttack"
public let kGAMEMOVE: String = "gameMove"
public let kMOVES: String = "moves"
public let kTURNCOUNT: String = "turnCount"
public let kROUNDNUMBER: String = "roundNumber"
public let kROUNDS: String = "rounds"
public let kGAMEID: String = "gameId"
public let kTIMESTAMP: String = "timeStamp"
public let kGAMEHISTORY: String = "gameHistory"
//public let kTURNCOUNTER: String = "turnCounter"

public let kOPPONENTNAME: String = "opponentName"
public let kOPPONENTAVATARTURL : String = "opponentAvatarUrl"
public let kHPLEFT: String = "hpLeft"

//storyboard VC Identifiers
public let kHOMEVIEWCONTROLLER: String = "homeVC"
public let kPREGAMEVIEWCONTROLLER: String = "preGameVC"
public let kGAMEVIEWCONTROLLER: String = "gameVC"
public let kGAMEOVERVIEWCONTROLLER: String = "gameOverVC"
public let kGAMEHISTORYVIEWCONTROLLER: String = "gameHistoryVC"
public let kGAMEHISTORYCELL: String = "gameHistoryCell"

//User info
public let kGAMESTATS: String = "gameStats" //this is for Firebase/users/uid/gameStats
public let kWINLOSESTAT: String = "winLoseStat"
public let kWINS: String = "wins"
public let kLOSES: String = "loses"
public let kMATCHESUID: String = "matchesUid"
public let kMATCHESDICTIONARY: String = "matchesDictionary"
public let kEXPERIENCES: String = "experiences"
public let kMAXEXPERIENCE: String = "maxExperience"
public let kLEVEL: String = "level"
public let kRESULT: String = "result"
public let kOPPONENTUID: String = "opponentUid"

//colors from UIColor extension
public let kCOLOR_FFFFFF: UIColor = UIColor(rgb: 0xFFFFFF)
public let kCOLOR_1B1E1F: UIColor = UIColor(rgb: 0x1B1E1F)
public let kCOLOR_5F6063: UIColor = UIColor(rgb: 0x5F6063)
public let kCOLOR_0E5C89: UIColor = UIColor(rgb: 0x0E5C89)
public let kCOLOR_F9F9F9: UIColor = UIColor(rgb: 0xF9F9F9)

public let kREDCGCOLOR = UIColor.red.cgColor
public let kCLEARCGCOLOR = UIColor.clear.cgColor
public let kGREENCGCOLOR = UIColor.green.cgColor

//fonts
public let kHEADERTEXT: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

//controller storyboard id
public let kCHATCONTROLLER: String = "chatController"
public let kLOGINCONTROLLER: String = "loginController"
public let kANIMATIONCONTROLLER: String = "animationController"
public let kMENUCONTROLLER: String = "menuController"

public let kREGISTEREDUSERS: String = "registeredUsers"
public let kPHONENUMBER: String = "phoneNumber"

public let kFINISHREGISTRATIONVC: String = "finishRegistrationVC"
public let kAUTHENTICATIONVC: String = "authenticationVC"

//Storyboard Identifiers
public let kTOAUTHENTICATIONVC: String = "toAuthenticationVC"
public let kTONAMEVC: String = "toNameVC"
public let kTOAUTHMENUVC: String = "toAuthMenuVC"
