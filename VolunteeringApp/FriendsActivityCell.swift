//
//  FriendsActivityCell.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import DateTools

class FriendsActivityCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    var delegate: FriendsViewController?
    
    var activity: PFObject? {
        didSet{
            
            let date = activity?.createdAt
            timeStampLabel.text = NSDate.shortTimeAgoSinceDate(date!)
            timeStampLabel.textColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0) // theme color
            
            Alamofire.request(.GET, activity!["user_image"] as! String).response{ (request, response, data, error) in
                self.profilePicture.image = UIImage(data: data!, scale: 1)
            }
            self.profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
            self.profilePicture.clipsToBounds = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FriendsActivityCell.onClickOnView))
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
            
            let type = activity!["type"] as? String
            let username = activity!["user"] as! String
            let activityName = activity!["activity_name"] as! String
            
            switch type! {
            case "followedOrg":
                self.activityLabel.text = "\(username) is now following \(activityName)"
            case "joinedEvent":
                self.activityLabel.text = "\(username) has joined the event \(activityName)"
            case "createdEvent":
                self.activityLabel.text = "\(username) has created the event \(activityName)"
            case "editedEvent":
                self.activityLabel.text = "\(username) has edited the event \(activityName)"
            default:
                self.activityLabel.text = "???"
            }
            
        } // end of didSet
    }  // end of activity PFObject
    
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
