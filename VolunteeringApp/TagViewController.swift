//
//  TagViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/18/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    var address = ""
    var coverImage: UIImage?
    var myDesc = ""
    var myTitle = ""
    var startDate: NSDate?
    var endDate: NSDate?
    
    @IBOutlet weak var constructionButton: UIButton!
    @IBOutlet weak var educationButton: UIButton!
    @IBOutlet weak var environmentButton: UIButton!
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var nutritionButton: UIButton!
    
    //@IBOutlet weak var checkImage: UIImageView!
    
    var editingEvent: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.constructionButton.layer.borderWidth = 1
        self.constructionButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).CGColor
        
        self.educationButton.layer.borderWidth = 1
        self.educationButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).CGColor
        
        self.environmentButton.layer.borderWidth = 1
        self.environmentButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).CGColor
        
        self.healthButton.layer.borderWidth = 1
        self.healthButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).CGColor
        
        self.nutritionButton.layer.borderWidth = 1
        self.nutritionButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).CGColor
        
        //checkImage.image = self.coverImage
        
        if editingEvent != nil {

        let tags = editingEvent!["tags"] as! [String]
        
        for tag in tags {
            if tag == "Construction" {
                constructionButton.setImage(UIImage(named: "checkmark"), forState: UIControlState.Normal)
            } else if tag == "Education" {
                educationButton.setImage(UIImage(named: "checkmark"), forState: UIControlState.Normal)
            } else if tag == "Environment" {
                environmentButton.setImage(UIImage(named: "checkmark"), forState: UIControlState.Normal)
            } else if tag == "Health" {
                healthButton.setImage(UIImage(named: "checkmark"), forState: UIControlState.Normal)
            } else if tag == "Nutrition" {
                nutritionButton.setImage(UIImage(named: "checkmark"), forState: UIControlState.Normal)
            }
        }

        // Do any additional setup after loading the view.
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeCheck(sender: UIButton) {
        if (sender.currentImage == nil) {
            sender.setImage(UIImage(named: "checkmark"), forState: UIControlState.Normal)
        } else {
            sender.setImage(nil, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func postEventClicked(sender: AnyObject) {
        let user = PFUser.currentUser()
        let hostImage = user!["orgProfile"] as! PFFile
        
        var tags: [String] = []
        if (constructionButton.currentImage != nil) {
            tags.append("Construction")
        }
        if (educationButton.currentImage != nil) {
            tags.append("Education")
        }
        if (environmentButton.currentImage != nil) {
            tags.append("Environment")
        }
        if (healthButton.currentImage != nil) {
            tags.append("Health")
        }
        if (nutritionButton.currentImage != nil) {
            tags.append("Nutrition")
        }
        
        if editingEvent == nil {
            Event.postEvent(coverImage, hostImage: hostImage, location: address, description: self.myDesc, startDate: self.startDate, endDate: self.endDate, title: self.myTitle, volunteers: [], tags: tags, withCompletion: nil)
        } else {
            Event.editEvent(editingEvent!, cover_image: coverImage, hostImage: hostImage, location: address, description: self.myDesc, startDate: self.startDate, endDate: self.endDate, title: self.myTitle, volunteers: [], tags: tags, withCompletion: nil)
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
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
