//
//  OrgRegisterViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class OrgRegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var registerButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.secureTextEntry = true
        imagePicker.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        
        nameField.placeholder = "Name"
        addressField.placeholder = "Address"
        cityField.placeholder = "City"
        stateField.placeholder = "State"
        emailField.placeholder = "Email"
        passwordField.placeholder = "Password"
        
        self.registerButton.layer.cornerRadius = registerButton.frame.size.width / 30
        self.registerButton.clipsToBounds = true
        self.registerButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.layer.masksToBounds = true
    }
    
    // choose the profile pic for the organization
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profilePic.contentMode = .ScaleAspectFit
            profilePic.image = originalImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /*
     add action to button to open the image library and choose the image
     */
    @IBAction func chooseImage(sender: AnyObject) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)

    }
   
    
    // ----------------------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func registerButtonTapped(sender: AnyObject) {
        let newuser = PFUser()
        newuser.username = emailField.text
        newuser.password = passwordField.text
        newuser["name"] = nameField.text
        newuser["address"] = addressField.text
        newuser["city"] = cityField.text
        newuser["state"] = stateField.text
        newuser["orgProfile"] = Event.getPFFileFromImage(profilePic.image)  // change the image to the one chosen from the library
        newuser["orgCover"] = Event.getPFFileFromImage(UIImage(named: "maroon-cover"))
        newuser["userType"] = "Organization"
        
        newuser.signUpInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
            if success {
                print("Yay, created a user!")
                self.performSegueWithIdentifier("orgRegisterSegue", sender: nil)
            }
            else {
                print(error?.localizedDescription)
                if error?.code == 202 {
                    print("Username is taken")
                }
            }
        }
        
    }
    
} // end of class
