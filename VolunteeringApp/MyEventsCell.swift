//
//  MyEventsCell.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import PrettyTimestamp

class MyEventsCell: UITableViewCell {
    
    @IBOutlet weak var coverPhotoView: PFImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    //@IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var cellBackgroundView: UIView!
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var eventLocation: CLLocation!
    
    
    //@IBOutlet weak var blurView: UIVisualEffectView!
    
    /*@IBOutlet weak var tagView1: UIImageView!
    @IBOutlet weak var tagView2: UIImageView!
    @IBOutlet weak var tagView3: UIImageView!
    @IBOutlet weak var tagView4: UIImageView!
    @IBOutlet weak var tagView5: UIImageView!*/
    
    var event: PFObject? {
        didSet {
            print("ENTERING INIT BLOCK")
            
            cellBackgroundView.layer.shadowColor = UIColor.darkGrayColor().CGColor
            cellBackgroundView.layer.shadowOffset = CGSizeMake(0, 0)
            cellBackgroundView.layer.shadowOpacity = 0.55
            cellBackgroundView.layer.shadowRadius = 5.0
            
            //self.blurView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            
            //self.blurView.effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            
            // ------------------------------------------------------------------------------------------------
             self.coverPhotoView.file = event!["cover_image"] as? PFFile
             self.coverPhotoView.loadInBackground()
             /*self.coverPhotoView.layer.masksToBounds = false
             self.coverPhotoView.layer.cornerRadius = coverPhotoView.frame.size.width / 2
             self.coverPhotoView.clipsToBounds = true*/
            // ------------------------------------------------------------------------------------------------
            
            self.titleLabel.text = event!["title"] as? String
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = .ShortStyle
            
            let startDate = event!["startDate"] as? NSDate
            let startDateString = startDate?.prettyTimestampSinceNow()
            //let replacedString = startDateString!.stringByReplacingOccurrencesOfString("ago", withString: "from now")
            self.dateLabel.text = startDateString
            
            let host = event!["host"] as! PFUser
            self.hostLabel.text = host["name"].description
            print(host.objectId)
            //self.hostLabel.text = user.username            
            //self.dateLabel.text = event!["date"] as? String
            /* DISTANCE FIELD REQUIRED HERE */
            
            //createTags(event!["tags"] as! [String])
            
            let address: String = event!["location"] as! String
            let geocoder: CLGeocoder = CLGeocoder()
            geocoder.geocodeAddressString(address,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if (placemarks?.count > 0) {
                    let topResult: CLPlacemark = (placemarks?[0])!
                    self.eventLocation = topResult.location!
                    
                    if self.currentLocation != nil {
                        let distance = self.currentLocation.distanceFromLocation(self.eventLocation)
                        let distanceString = Constant.distanceToMilesAway(distance)
                        self.distanceLabel.text = distanceString
                        //self.distanceLabel.textColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0)
                    }
                }
            })
        }
    }
    
    /*func createTags(tags: [String]) {
        var tagIndex = 1
        for tag in tags {
            if tag == "Construction" {
                indexToTag(tagIndex, imageString: "construction")
            } else if tag == "Education" {
                indexToTag(tagIndex, imageString: "education")
            } else if tag == "Environment" {
                indexToTag(tagIndex, imageString: "environment")
            } else if tag == "Nutrition" {
                indexToTag(tagIndex, imageString: "food")
            } else if tag == "Health" {
                indexToTag(tagIndex, imageString: "health")
            }
            tagIndex += 1
        }
        for index in tagIndex...6 {
            if index == 1 {
                tagView1.image = nil
            } else if index == 2 {
                tagView2.image = nil
            } else if index == 3 {
                tagView3.image = nil
            } else if index == 4 {
                tagView4.image = nil
            } else if index == 5 {
                tagView5.image = nil
            }
        }
    }
    
    func indexToTag(index: Int, imageString: String) {
        if index == 1 {
            tagView1.image = UIImage(named: imageString)
        } else if index == 2 {
            tagView2.image = UIImage(named: imageString)
        } else if index == 3 {
            tagView3.image = UIImage(named: imageString)
        } else if index == 4 {
            tagView4.image = UIImage(named: imageString)
        } else if index == 5 {
            tagView5.image = UIImage(named: imageString)
        }
    }*/


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
