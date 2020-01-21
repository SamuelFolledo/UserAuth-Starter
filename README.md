#  Firebase User Authentication Starter Code
### The goal of this API is to be forked, used as a started code, and easily have User Authentication without hours of setting up.

## Why Use?
- **Hackathons** participants that wants to have a quick Firebase User Authentication built in your app with as little effort and time wasted as possible
- **Prototyping** apps to immediately see a live app with P2P features and connectivity
- **Learning** Firebase Authentication: *email login/register, Facebook login/register, phone login/register, anonymous signin*

## How to Setup?
1.  __Fork and Change Directory in Terminal__
2. __Install the pods__ in the terminal by running:
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
- __[Facebook For Developers](https://developers.facebook.com/)__
    - [Firebase's Instructions for Facebook Login](https://firebase.google.com/docs/auth/ios/facebook-login?authuser=0)
- __[Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)__
    - [Firebase's Instructions Google Signin Instructions](https://firebase.google.com/docs/auth/ios/google-signin)
    - Sometimes turning a UIButton in storyboard to a GIDSignInButton does not work, so open the storyboard file as a Source Code and customize it there 
- [Sign in With Apple]() - only works for members with [Apple Developer Program](https://developer.apple.com/programs/)
    - [Firebase's Instructions for Sign in With Apple](https://firebase.google.com/docs/auth/ios/apple?authuser=0)
    - [Apple Signin video reference](https://www.youtube.com/watch?v=MY5xLrsnUVo)
    
- Used these as reference
    - [Facebook Signin Video pt 1](https://www.youtube.com/watch?v=7DdgvI8z6OU)
    - [Facebook Signin Video pt 2](https://www.youtube.com/watch?v=8-WXdfjFvbw)
        - __Note__ that Facebook updates very often, so keep checking for future updates
        - You will need to create your app in __[Facebook For Developers](https://developers.facebook.com/)__
        - In developers.facebook.com, you will also need to go to your project's Settings and see the __Client OAuth Settings__ and paste _OAuth redirect URI from Firebase's project -> Authentication -> Sign-in method -> Facebook_ (e.g.https://folledouserauth.firebaseapp.com/__/auth/handler) into Valid OAuth Redirect URIs
        - You will also need to remove my 2 Facebook code blocks in Info.plist file and put yours instead.
        - [Fetching the Facebook User Data](https://riptutorial.com/ios/example/10188/fetching-the-facebook-user-data)
        
    - [Google Signin Video](https://www.youtube.com/watch?v=BjsJNpgsl5c)


### Note for Phone Authentication:
Don't forget to:
- to paste Google-Sevice-Info.plist's REVERSE_CLIENT_ID's value in the project -> Info -> URL Types -> + //Comitted on January, 4 2019
- APNs Certificates are required to be uploaded in your Firebase project's Project Settings -> Cloud Messaging -> iOS app configuration __which needs to be updated annually__ //Comitted on January, 4 2019
    - [Configuring APNs with FCM](https://firebase.google.com/docs/cloud-messaging/ios/certs)




## Login View
<img src="https://github.com/SamuelFolledo/UserAuth-Starter/blob/master/FolledoUserAuth/assets/login.png" width="310" height="550`"> 

## Register View
<img src="https://github.com/SamuelFolledo/UserAuth-Starter/blob/master/FolledoUserAuth/assets/register.png" width="310" height="550`"> 

License under the [MIT License](LICENSE)
