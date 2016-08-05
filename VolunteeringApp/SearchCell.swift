//
//  SearchCell.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/18/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import ParseUI

class SearchCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var user: PFObject? {
        didSet{
            
            profileImageView.file = user!["orgProfile"] as? PFFile
            profileImageView.loadInBackground()
            nameLabel.text = user!["name"] as? String
            
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
