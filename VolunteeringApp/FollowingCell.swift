//
//  FollowingCell.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/29/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class FollowingCell: UITableViewCell {

    @IBOutlet weak var profileView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var cellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellBackgroundView.layer.shadowColor = UIColor.darkGrayColor().CGColor
        cellBackgroundView.layer.shadowOffset = CGSizeMake(0, 0)
        cellBackgroundView.layer.shadowOpacity = 0.55
        cellBackgroundView.layer.shadowRadius = 5.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var organization: PFUser? {
        didSet {
            print(organization)
            organization?.fetchInBackgroundWithBlock({ (updatedOrganization: PFObject?, error: NSError?) in
                if error == nil {
                    self.completeOrganization = updatedOrganization as? PFUser
                }
            })
        }
    }
    
    var completeOrganization: PFUser? {
        didSet {
            self.nameLabel.text = completeOrganization!["name"].description
            self.profileView.layer.cornerRadius = profileView.frame.size.width / 2
            self.profileView.clipsToBounds = true
            self.profileView.file = completeOrganization!["orgProfile"] as? PFFile
            self.profileView.loadInBackground()
        }
    }

}
