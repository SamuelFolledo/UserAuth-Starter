# User Authentication Starter Code

### The goal of this API is to be forked, used as a started code, and easily have User Authentication without hours of setting up.

## Why Use?
- **Hackathons** participants that wants to have a quick Firebase User Authentication built in your app with as little effort and time wasted as possible
- **Prototyping** apps to immediately see a live app with P2P features and connectivity
- **Learning** Firebase Authentication: *email login/register, Facebook login/register, phone login/register, anonymous signin*

## Live Demo
<p align="center">
<img src="https://media.giphy.com/media/ejyzvhao81HLRjrOXX/giphy.gif" width="404" height="720">
</p>


## How to Setup?
1.  **Fork and Change Directory in Terminal**
2. **Install the pods** in the terminal by running:
    `
    $ pod install
    `
3. Create Project in Firebase
4. Enable Authentication and Real Time Database
5. Test

## Update pods
- To be safe, run the following commands to ensure all pods are up to date
```
pod update
```
- **[Facebook For Developers](https://developers.facebook.com/)**
    - [Firebase's Instructions for Facebook Login](https://firebase.google.com/docs/auth/ios/facebook-login?authuser=0)
- **[Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)**
    - [Firebase's Instructions Google Signin Instructions](https://firebase.google.com/docs/auth/ios/google-signin)
    - Sometimes turning a UIButton in storyboard to a GIDSignInButton does not work, so open the storyboard file as a Source Code and customize it there 
- [Sign in With Apple]() - only works for members with [Apple Developer Program](https://developer.apple.com/programs/)
    - [Firebase's Instructions for Sign in With Apple](https://firebase.google.com/docs/auth/ios/apple?authuser=0)
    - [Apple Signin video reference](https://www.youtube.com/watch?v=vuygdr0EcGM)
        1. Enable Apple Signin in Firebase
        2. Add **Sign In With Apple** capability in you Xcode project's Signing & Capabilities
        3. In Apple Developer, signin and look for your projecct. Enable Signin With Apple in [Identifiers list](https://developer.apple.com/account/resources/identifiers/list)
        4. 
    - [Apple Signin video reference - SwiftUI and FireStore](https://www.youtube.com/watch?v=MY5xLrsnUVo)
    
- Used these as reference
    - [Facebook Signin Video pt 1](https://www.youtube.com/watch?v=7DdgvI8z6OU)
    - [Facebook Signin Video pt 2](https://www.youtube.com/watch?v=8-WXdfjFvbw)
        - **Note** that Facebook updates very often, so keep checking for future updates
        - You will need to create your app in **[Facebook For Developers](https://developers.facebook.com/)**
        - In developers.facebook.com, you will also need to go to your project's Settings and see the **Client OAuth Settings** and paste _OAuth redirect URI from Firebase's project -> Authentication -> Sign-in method -> Facebook_ (e.g.https://folledouserauth.firebaseapp.com/**/auth/handler) into Valid OAuth Redirect URIs
        - You will also need to remove my 2 Facebook code blocks in Info.plist file and put yours instead.
        - [Fetching the Facebook User Data](https://riptutorial.com/ios/example/10188/fetching-the-facebook-user-data)
    - [Google Signin Video](https://www.youtube.com/watch?v=BjsJNpgsl5c)


### Note for Phone Authentication:
Don't forget to:
- to paste Google-Sevice-Info.plist's REVERSE_CLIENT_ID's value in the project -> Info -> URL Types -> + //Comitted on January, 4 2019
- APNs Certificates are required to be uploaded in your Firebase project's Project Settings -> Cloud Messaging -> iOS app configuration **which needs to be updated annually** //Comitted on January, 4 2019
    - [Configuring APNs with FCM](https://firebase.google.com/docs/cloud-messaging/ios/certs)




## AuthMenu Screen
Where users can select from either Sign In with Apple, Facebook, Google, Phone, or Email. Using Facebook or Google will take your profile picture if allowed

<img src="https://github.com/SamuelFolledo/UserAuth-Starter/blob/master/static/version2/authMenu.PNG" width="466" height="828"> 


## Phone Auth/Email Auth Screen
Signin or register via phone or email authentication. It will know if phone or email already exist in the database, and will either log in or register user accordingly.

<img src="https://github.com/SamuelFolledo/UserAuth-Starter/blob/master/static/version2/phoneAuth.PNG" width="466" height="828"> 


## Account Table
User can view their profile picture and logout. (Upcoming features are, delete account from account settings, update names and profile picture)

<img src="https://github.com/SamuelFolledo/UserAuth-Starter/blob/master/static/version2/accountTableView.PNG" width="466" height="828"> 


License under the [MIT License](LICENSE)
