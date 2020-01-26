//
//  AuthMenuVC.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/12/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices //for Apple Signin

class AuthMenuVC: UIViewController {
//MARK: Properties
    fileprivate var currentNonce: String? //for Apple Auth = random ID token as string
    
//MARK: IBOulets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: FBLoginButton!
    @IBOutlet weak var appleButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUp()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LoginManager().logOut() //logout the button
    }
    
//MARK: Methods
    func setUp() {
        setupAppleButton()
        setupFacebookButton()
        setupGoogleButton()
        phoneButton.isAuthButton()
        emailButton.isAuthButton()
    }
    
//MARK: IBActions
    @IBAction func emailButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: true)
    }
    @IBAction func phoneButtonTapped(_ sender: Any) {
        Service.toAuthenticationVC(fromVC: self, isEmailAuth: false)
    }
    
    @IBAction func googleButtonTapped(_ sender: Any) {
//        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Google is still under production. Check back at a later time")
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        //        Service.presentAlert(on: self, title: "Not Released Yet", message: "Continue with Facebook is still under production. Check back at a later time")
    }
    
//MARK: Helpers
    @objc func appleButtonTapped() {
        currentNonce = randomNonceString()
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce!)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request]) //screen for Apple signin
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests() //perform the request in this VC
    }
    
    fileprivate func setupAppleButton() {
        let newAppleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black) //.continue = "Continue With Apple", .black for black button
        newAppleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addSubview(newAppleButton)
        NSLayoutConstraint.activate([
            newAppleButton.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor),
            newAppleButton.leadingAnchor.constraint(equalTo: appleButton.leadingAnchor),
            newAppleButton.trailingAnchor.constraint(equalTo: appleButton.trailingAnchor),
            newAppleButton.widthAnchor.constraint(equalTo: appleButton.widthAnchor),
            newAppleButton.heightAnchor.constraint(equalTo: appleButton.heightAnchor),
        ])
//        newAppleButton.frame = appleButton.frame
//        appleButton = newAppleButton
//        appleButton = ASAuthorizationAppleIDButton(authorizationButtonType: .continue, authorizationButtonStyle: .black) //.continue = "Continue With Apple", .black for black button
        appleButton.layer.cornerRadius = appleButton.frame.height / 10
        appleButton.clipsToBounds = true
        newAppleButton.addTarget(self, action: #selector(AuthMenuVC.appleButtonTapped), for: .touchUpInside)
//        appleButton.addTarget(self, action: #selector(AuthMenuVC.appleButtonTapped), for: .touchUpInside)
    }
    
    fileprivate func setupGoogleButton() {
        googleButton.isAuthButton()
        // Shadow and Radius
        googleButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        googleButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        googleButton.layer.shadowOpacity = 1.0
        googleButton.layer.shadowRadius = 0.0
        googleButton.layer.masksToBounds = false //needed or shadow wont show
    }
    
    fileprivate func setupFacebookButton() { //setup facebook button and its font size
        facebookButton.isAuthButton()
//        let fbButton = FBLoginButton(frame: facebookButton.center, permissions: [.publicProfile]) //programmatically create one
        facebookButton.permissions = [ "public_profile", "email", "user_photos"] //get public profile, email, photos, and about me
        let font = UIFont.boldSystemFont(ofSize: 18) //bold system, size 18
        let fbTitle = NSAttributedString.init(string: "Continue with Facebook", attributes: [NSAttributedString.Key.font : font])
        facebookButton.setAttributedTitle(fbTitle, for: .normal)
        facebookButton.delegate = self
    }
}

//MARK: Facebook Auth
extension AuthMenuVC: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) { //Delegate method that will run once login has been completed with Facebook button. Result can be, fail, cancel, or success
        if let error = error {
            Service.presentAlert(on: self, title: "Facebook Error", message: error.localizedDescription)
            return
        }
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView() as UIActivityIndicatorView
        spinner.style = .large
        spinner.center = view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        guard let result = result else { return }
        if result.isCancelled { //if user canceled login
            print("User canceled Facebook Login")
            spinner.stopAnimating()
        } else { //if fb login is successful
            if result.grantedPermissions.contains("email") { //make sure they gave us permissions
                let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name, picture.type(large)"])
                graphRequest.start { (connection, graphResult, error) in //start a connection with Graph API
                    if let error = error {
                        spinner.stopAnimating()
                        Service.presentAlert(on: self, title: "Facebook Error", message: error.localizedDescription)
                        return
                    } else {
                        guard let userDetails: [String: AnyObject] = graphResult as? [String: AnyObject] else { //contain user's details
                            spinner.stopAnimating()
                            print("No User Details")
                            return
                        }
                        print("USER DETAILS = \(userDetails)")
                        self.fetchFacebookUserWithUserDetails(userDetails: userDetails)
                    }
                }
                spinner.stopAnimating()
            } else { //result.grantedPermissions = false
                spinner.stopAnimating()
                Service.presentAlert(on: self, title: "Facebook Error", message: "Facebook failed to grant access")
                return
            }
        }
        print("Successfully logged in Facebook")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) { //Delegate Method - Logout
        print("User logged out!")
    }
    
    fileprivate func fetchFacebookUserWithUserDetails(userDetails: [String: AnyObject]) { //fetch user's details from facebook and create that user class and go to next controller
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView() as UIActivityIndicatorView //spinner
        spinner.style = .large
        spinner.center = view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        guard let accessToken = AccessToken.current?.tokenString else { print("Failed to get current Facebook token"); return }
        getFacebookUser(userDetails: userDetails, accessToken: accessToken) { (user, error) in
            if let error = error {
                LoginManager().logOut() //Do not log user in
                Service.presentAlert(on: self, title: "Facebook Error", message: error)
                return
            }
            goToNextController(vc: self, user: user!)
        }
        spinner.stopAnimating()
    }
}

//MARK: Google Signin Delegate Methods
extension AuthMenuVC: GIDSignInDelegate {
    func signInWillDispatch(_ signIn: GIDSignIn!, error: Error!) {
        print("GOOGLE SIGNINWILLDISPATCH?")
        // myActivityIndicator.stopAnimating()
    }
    
    func signIn(_ signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) { //presents the google signin screen
        self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(_ signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) { //when user dismisses the google signin screen
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            Service.presentAlert(on: self, title: "Google Authentication Error", message: error.localizedDescription)
            return
        } else {
            //MARK: USE user.userID as password and objectId
//            let userId = user.userID // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
            print("USER = \(user)")
            print("USER PROFILE = \(user.profile.debugDescription)")
            print("USER DESCRIPTION = \(user.profile.description.debugDescription)")
            print("USER ID \(user.userID)\nAUTH AUTH ID \(user.authentication.idToken)\nACCESSTOKEN \(user.authentication.accessToken)") //access token is what allows you to get into the database. //idToken is
            let firstName = user.profile.givenName ?? ""
            let lastName = user.profile.familyName ?? ""
            let email = user.profile.email ?? ""
            var userDetails = [kFIRSTNAME: firstName, kLASTNAME: lastName, kEMAIL: email]
            if user.profile.hasImage {
                let imageUrl = user.profile.imageURL(withDimension: 100)
                print("\(firstName)'s Image URL from Google = \(String(describing: imageUrl))")
                userDetails[kIMAGEURL] = imageUrl?.absoluteString
            }
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            User.authenticateUser(credential: credential, userDetails: userDetails) { (user, error) in //authenticate user with credentials and get user
                if let error = error {
                    Service.presentAlert(on: self, title: "Google Error", message: error)
                    return
                }
                goToNextController(vc: self, user: user!)
            }
        }
    }
}

//MARK: Apple Signin Delegate methods
extension AuthMenuVC: ASAuthorizationControllerDelegate { //delegate if the vc that pops up fails or successful
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) { //successful Apple Auth
        switch authorization.credential {
        case let appleCredential as ASAuthorizationAppleIDCredential: //if this was Apple User object...
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
//            let id = appleCredential.user as? String ?? ""
            let firstName: String = appleCredential.fullName?.givenName ?? ""
            let lastName: String = appleCredential.fullName?.familyName ?? ""
            let email: String = appleCredential.email ?? ""
            let userDetails: [String: Any] = [kFIRSTNAME: firstName, kLASTNAME: lastName, kEMAIL: email]
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce) // Initialize a Firebase credential.
            User.authenticateUser(credential: credential, userDetails: userDetails) { (user, error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Apple Authentication Error", message: error)
                    return
                }
                goToNextController(vc: self, user: user!)
            }
        default:
            print("Apple Auto login")
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) { //error Apple Auth
        Service.presentAlert(on: self, title: "Apple Authentication Error", message: error.localizedDescription)
    }
}

extension AuthMenuVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor { //this says what window are we presenting in e.g. iPad etc.
        return view.window!
    }
}
