//
//  HomeViewController.swift
//  FacebookLoginMiniApp
//
//  Created by Danny Tan on 7/3/16.
//  Copyright © 2016 Danny Tan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase


class HomeViewController: UIViewController {
    //MARK: Property
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var ref = FIRDatabase.database().referenceFromURL("https://facebooklogin-50952.firebaseio.com/")
    var user = FIRAuth.auth()?.currentUser
    
    //MARK: Action
    @IBAction func didLogOut(sender: AnyObject) {
        
        //signs the user out of Firebase
        try! FIRAuth.auth()!.signOut()
        
        //signs out of facebook
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginView")
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let user = FIRAuth.auth()?.currentUser {
            //refers to storage
            let storage = FIRStorage.storage()
            let storageRef = storage.referenceForURL("gs://facebooklogin-50952.appspot.com")
            let profilePicRef = storageRef.child(user.uid+"/profile_pic.jpg")
            
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print ("File does not exist")
                } else {
                    if (data != nil){
                        self.profilePic.image = UIImage(data:data!)
                    }
                    // Data for "images/island.jpg" is returned
                    // ... let islandImage: UIImage! = UIImage(data: data!)
                }
            }
                
            if(self.profilePic.image == nil){
                var profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300,"width" : 300, "redirect": false], HTTPMethod: "GET")
                profilePic.startWithCompletionHandler({(connection, result, error) -> Void in
                    if (error == nil)
                        {
                            let dictionary = result as? NSDictionary
                            let data = dictionary?.objectForKey("data")
                    
                            let urlPic = (data?.objectForKey("url")) as! String
                    
                            if let imageData = NSData(contentsOfURL: NSURL (string:urlPic)!)
                            {
                                let uploadTask = profilePicRef.putData(imageData, metadata: nil){
                                    metadata, error in
                                    if(error == nil)
                                    {
                                        let downloadURL = metadata!.downloadURL
                                    }
                                    else{
                                        print ("Error in downloading image")
                                    }
                                }
                        
                                self.profilePic.image = UIImage(data:imageData)
                            }
                    }
                })
            }
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, id, birthday, gender, email, picture.type(large), education"]).startWithCompletionHandler{(connection, result, error) -> Void in
                
                if error != nil {
                    print (error)
                    return
                }
                if let userName = result ["name"] as? String {
                    self.ref.child("user").child("\(user.uid)/name").setValue(userName)
                    self.userName.text = userName
                }
                
                if let profileID = result ["id"] as? String {
                    self.ref.child("user").child("\(user.uid)/ID").setValue(profileID)
                }
                
                if let gender = result ["gender"] as? String {
                    self.ref.child("user").child("\(user.uid)/gender").setValue(gender)
                }
                if let birthday = result ["birthday"] as? String {
                    self.ref.child("user").child("\(user.uid)/birthday").setValue(birthday)
                }
                if let email = result ["email"] as? String {
                    self.ref.child("user").child("\(user.uid)/email").setValue(email)
                }
                if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                    self.ref.child("user").child("\(user.uid)/picture").setValue(url)
                }
                if let education = result["education"] as? NSArray, school = education[education.count - 1]["school"] as? NSDictionary, schoolName = school["name"] {
                    self.ref.child("user").child("\(user.uid)/school").setValue(schoolName)
                }
            }
        }
        else {
                // No user is signed in.
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"doYourStuff", name:
            UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func doYourStuff(){
        var ref = FIRDatabase.database().referenceFromURL("https://facebooklogin-50952.firebaseio.com/")
        var user = FIRAuth.auth()?.currentUser
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, id, birthday, gender, email, picture.type(large), education"]).startWithCompletionHandler{(connection, result, error) -> Void in
            
            if error != nil {
                print (error)
                return
            }
            if let userName = result ["name"] as? String {
                self.ref.child("user").child("\(user!.uid)/name").setValue(userName)
                self.userName.text = userName
            }
            
            if let profileID = result ["id"] as? String {
                self.ref.child("user").child("\(user!.uid)/ID").setValue(profileID)
            }
            
            if let gender = result ["gender"] as? String {
                self.ref.child("user").child("\(user!.uid)/gender").setValue(gender)
            }
            if let birthday = result ["birthday"] as? String {
                self.ref.child("user").child("\(user!.uid)/birthday").setValue(birthday)
            }
            if let email = result ["email"] as? String {
                self.ref.child("user").child("\(user!.uid)/email").setValue(email)
            }
            if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                self.ref.child("user").child("\(user!.uid)/picture").setValue(url)
            }
            if let education = result["education"] as? NSArray, school = education[education.count - 1]["school"] as? NSDictionary, schoolName = school["name"] {
                self.ref.child("user").child("\(user!.uid)/school").setValue(schoolName)
            }
            if let ageRange = result["age"] as? String {
                self.ref.child("user").child("\(user!.uid)/age").setValue(ageRange)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
