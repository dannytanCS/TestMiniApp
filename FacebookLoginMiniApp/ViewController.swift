//
//  ViewController.swift
//  FacebookLoginMiniApp
//
//  Created by Danny Tan on 7/3/16.
//  Copyright © 2016 Danny Tan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var loginButton: FBSDKLoginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                //move to main menu
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainMenu")
                self.presentViewController(homeViewController, animated: true, completion: nil)
            } else {
                // No user is signed in.
                // Optional: Place the button in the center of your view.
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile","user_birthday", "email", "user_friends", "user_education_history"]
                self.loginButton.delegate = self
                self.view!.addSubview(self.loginButton)
                self.loginButton.hidden = false
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print ("User logged in")
        self.loginButton.hidden = true
        
        if (error != nil){
            self.loginButton.hidden = false
        }
        else if(result.isCancelled){
            //if they cancel to accept the facebook login
            self.loginButton.hidden = false
        }
        else{
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                
                print("User logged in through Firebase app")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        print ("User did logout")
        }
}



