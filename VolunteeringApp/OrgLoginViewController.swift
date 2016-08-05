//
//  OrgLoginViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class OrgLoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.placeholder = "Email"
        passwordField.placeholder = "Password"
        
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.cornerRadius = loginButton.frame.size.width / 30
        loginButton.clipsToBounds = true
        
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor.whiteColor().CGColor
        registerButton.layer.cornerRadius = registerButton.frame.size.width / 30
        registerButton.clipsToBounds = true
        
        passwordField.secureTextEntry = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*@IBAction func exitButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }*/
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(emailField.text!, password: passwordField.text!) { (user: PFUser?, error: NSError?) -> Void in
            if user != nil  {
                print("you're logged in")
                self.performSegueWithIdentifier("orgLoginSegue", sender: nil)
                print("segue")
            }
        }

    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
