//
//  OrgEventsCell.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/13/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import ParseUI

class OrgEventsCell: UITableViewCell {

    //@IBOutlet weak var coverPhotoView: PFImageView!
    @IBOutlet weak var titleLabel: UILabel!
    //@IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var coverPhotoView: PFImageView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var cellBackgroundView: UIView!
    
    var delegate: OrgProfileViewController?
    
    var event: PFObject? {
        didSet {
            print("ENTERING INIT BLOCK")
            
            cellBackgroundView.layer.shadowColor = UIColor.darkGrayColor().CGColor
            cellBackgroundView.layer.shadowOffset = CGSizeMake(0, 0)
            cellBackgroundView.layer.shadowOpacity = 0.55
            cellBackgroundView.layer.shadowRadius = 5.0
            
            let address: String = event!["location"] as! String
            //self.locationLabel.text = address
            // ------------------------------------------------------------------------------------------------
            self.coverPhotoView.file = event!["cover_image"] as? PFFile
            self.coverPhotoView.loadInBackground()
            /*self.coverPhotoView.layer.masksToBounds = false
            self.coverPhotoView.layer.cornerRadius = coverPhotoView.frame.size.width / 2
            self.coverPhotoView.clipsToBounds = true*/
            // ------------------------------------------------------------------------------------------------
            
            self.titleLabel.text = event!["title"] as? String
            let startDate = event!["startDate"] as? NSDate
            let startDateString = startDate?.prettyTimestampSinceNow()
            //let startDateString = formatter.stringFromDate(startDate!)
            self.dateLabel.text = startDateString?.stringByReplacingOccurrencesOfString("ago", withString: "from now")

            let user = event!["host"] as! PFUser
            print(user.objectId)
            
            let currentUser = PFUser.currentUser()
            if currentUser!.objectId != user.objectId {
                deleteButton.hidden = true
                editButton.hidden = true
            }
            //self.hostLabel.text = user.username
            //self.dateLabel.text = event!["date"] as? String
            /* DISTANCE FIELD REQUIRED HERE */
        }
    }

    @IBAction func deleteButtonDidTap(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure?", message: "All information related to this event will be deleted.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let leaveAction = UIAlertAction(title: "Delete event", style: .Destructive) { (action) in
            self.event?.deleteInBackgroundWithBlock({ (deleted: Bool, error: NSError?) in
                if error == nil {
                    self.delegate!.deletedEvent()
                }
            })
        }
        alertController.addAction(leaveAction)
        
        self.delegate!.presentViewController(alertController, animated: true) {
            // ...
        }

    }
    
    @IBAction func editButtonDidTap(sender: AnyObject) {
        self.delegate!.performSegueWithIdentifier("orgProfileToCreateEventSegue", sender: self)
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
