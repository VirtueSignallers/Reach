//
//  ViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/6/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4
import AFNetworking
import ESTabBarController

class ViewController: UIViewController, PFLogInViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signInButtonTapped(sender: AnyObject) {
    PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email", "user_friends"]) { (user: PFUser?, error: NSError?) in
            if error != nil
            {
                print("Error: " + error!.localizedDescription)
            }
            else {
                print(user)
                print("Current user token=\(FBSDKAccessToken.currentAccessToken().tokenString)")
            
                let accessToken = FBSDKAccessToken.currentAccessToken()
                
                // ----------------------------------------------------------------------------------------------------------------------------------------------------------
                // getting information about the friends
                let fbRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil, tokenString: accessToken.tokenString, version: nil, HTTPMethod: "GET")
                fbRequest.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                    if error == nil {
                        print("DATA:\(result.valueForKey("data") as! NSArray)")
                        let userDataArray = result.valueForKey("data") as! NSArray
                        var idArray: Array <String> = []
                        for stuff in userDataArray {
                           idArray.append(stuff.valueForKey("id") as! String)
                        }
                        user?["friend_id_array"] = idArray
                        print("IDs:\(idArray)")
                    } else {
                        print(error.localizedDescription)
                    }
                })
                // ----------------------------------------------------------------------------------------------------------------------------------------------------------
                
                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: accessToken.tokenString, version: nil, HTTPMethod: "GET")
                req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
                    if(error == nil)
                    {
                        print("result \(result)")
                        let user = PFUser.currentUser()
                        let userEmail = result.valueForKey("email") as! String
                        let name = result.valueForKey("name") as? String
                        let id = result.valueForKey("id") as! String
                        let pictureURL = "https://graph.facebook.com/\(id)/picture?type=large&return_ssl_resources=1"
                        
                        user!["id"] = id

                        user!.email = userEmail

                        user!["name"] = name
                        user!["profilePicture"] = pictureURL
                        user!["userType"] = "Volunteer"
                        
                        if user!["subscribed"] == nil {
                            user!["subscribed"] = []
                        }
                        
                        if user!["achievements"] == nil {
                            user!["achievements"] = []
                        }
                        
                        user!.saveInBackground()
                        
//                        let tabBarController = ESTabBarController(tabIconNames: ["Discover", "Friends", "Search", "Me"])
//                        
//                        let mainStoryboard = self.storyboard
//                        let discoverNC = mainStoryboard?.instantiateViewControllerWithIdentifier("NearbyNC")
//                        let friendsNC = mainStoryboard?.instantiateViewControllerWithIdentifier("FriendsNC")
//                        let organizationSearchVC = mainStoryboard?.instantiateViewControllerWithIdentifier("OrganizationSearch")
//                        let meNC = mainStoryboard?.instantiateViewControllerWithIdentifier("MeNC")
//                        tabBarController.setViewController(discoverNC, atIndex: 0)
//                        tabBarController.setViewController(friendsNC, atIndex: 1)
//                        tabBarController.setViewController(organizationSearchVC, atIndex: 2)
//                        tabBarController.setViewController(meNC, atIndex: 3)
//                        
//                        tabBarController.selectedColor = Constant.themeColor
//                        tabBarController.buttonsBackgroundColor = UIColor.grayColor()
//                        
//                        self.presentViewController(tabBarController, animated: true, completion: nil)
                        
                        self.performSegueWithIdentifier("userLoginSegue", sender: nil)
                        
                    }
                    else
                    {
                        print("error \(error)")
                    }
                })
            }
        
        }

    }
} // end of class

