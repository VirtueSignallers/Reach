//
//  OrgActivityCell.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/15/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Alamofire

class OrgActivityCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    
    var delegate: OrgActivityViewController?
    
    var activity: PFObject? {
        didSet{
            
            //print(activity!["user_image"] as! String)
            Alamofire.request(.GET, activity!["user_image"] as! String).response{ (request, response, data, error) in
                self.profilePicture.image = UIImage(data: data!, scale: 1)
            }
            
            profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
            profilePicture.layer.masksToBounds = true 
            
            let type = activity!["type"] as? String
            let username = activity!["user"] as! String
            let activityName = activity!["activity_name"] as! String
            
            if type == "followedOrg" {
                self.activityLabel.text = "\(username) has subscribed to you"
            } else if type == "joinedEvent"{
                self.activityLabel.text = "\(username) has joined your event \(activityName)"
            }
            else if type == "createdEvent" {
                self.activityLabel.text = "You created the event \(activityName)"
            }
            else if type == "editedEvent" {
                self.activityLabel.text = "You edited the event \(activityName)"
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OrgActivityCell.onClickOnView))
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
            
        }
    }
    
    func onClickOnView(){
        let query = PFQuery(className: "_User")
        // query.includeKey("_auth_data_facebook")
        query.whereKey("name", equalTo: activity!["user"])
        query.findObjectsInBackgroundWithBlock { (users: [PFObject]?, error: NSError?) in
            if error == nil {
                let userID = self.activity!["userFBID"] as! String
                let orgID = self.activity!["orgID"] as! String
                if userID == "" {
                    for user in users! {
                        if user.objectId == orgID {
                            self.delegate?.segueToOrgProfile(user as! PFUser)
                        }
                    }
                } else {
                    for user in users! {
                        if user["id"] as! String == userID {
                            self.delegate?.segueToUserProfile(user as! PFUser, image: self.profilePicture.image!)
                        }
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
