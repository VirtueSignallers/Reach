//
//  EventDetailViewController.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import MapKit
import EventKit
import ParseUI
import Parse
import ASHorizontalScrollView
import Alamofire

class EventDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var coverPhotoView: PFImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var hostProfileView: PFImageView?
    @IBOutlet weak var hostNameLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var locationLabel: UILabel?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var joinButton: UIButton?
    @IBOutlet weak var mapView: MKMapView?
    
    @IBOutlet weak var horizontalScrollView: ASHorizontalScrollView!
    @IBOutlet weak var noneView: UIImageView!
    
    @IBOutlet weak var horizontalScrollViewWidth: NSLayoutConstraint!
    
    var joined: Bool = false
    var event: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        if (self.navigationController != nil) {
          self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        }
        let volunteers = event!["attending"] as! [PFUser]
        print(volunteers)
        
        for volunteer in volunteers {
            if volunteer.objectId == PFUser.currentUser()?.objectId {
                joined = true
            }
        }
        
        //This must be called after changing any size or margin property of this class to get acurrate margin
        horizontalScrollView.setItemsMarginOnce()
        var buttonX: CGFloat = 0
        if volunteers.count != 0 {
            noneView.hidden = true
            for (index, volunteer) in volunteers.enumerate() {
                let button = UIButton()
                //button.backgroundColor = UIColor.blueColor()
                
                Alamofire.request(.GET, volunteer["profilePicture"] as! String).response{ (request, response, data, error) in
                    button.setImage(UIImage(data: data!, scale: 1)
                        , forState: UIControlState.Normal)
                    button.setTitle(String(index), forState: UIControlState.Normal)
                    button.frame = CGRectMake(buttonX, 0, 45, 45)
                    buttonX += 50
                    button.layer.masksToBounds = false
                    button.clipsToBounds = true
                    button.layer.cornerRadius = button.frame.size.width / 2
                    button.addTarget(self, action: #selector(self.segueToUserProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }
                horizontalScrollView.addItem(button)
            }
        } else {
            // noneView.layer.masksToBounds = false
            noneView.layer.zPosition = 100
            noneView.clipsToBounds = true
            noneView.layer.cornerRadius = noneView.frame.size.width / 2
        }
        
//        self.view.addSubview(horizontalScrollView)
        scrollView.addSubview(horizontalScrollView)
        
        // handling and formatting the date
        let startDate = event!["startDate"] as? NSDate
        let endDate = event!["endDate"] as? NSDate
        // history event: joinButton disabled
        if (startDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending) {
            joinButton?.setTitle("Event has passed", forState: UIControlState.Normal)
            joinButton!.enabled = false
        } else if (joined) {
            joinButton?.setTitle("Leave event", forState: UIControlState.Normal)
        } else {
            joinButton?.setTitle("Join event", forState: UIControlState.Normal)
        }
        
        let color = Constant.themeColor.colorWithAlphaComponent(0.8)
        joinButton!.backgroundColor = color
        
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .ShortStyle
        let startDateString = formatter.stringFromDate(startDate!)
        let endDateString = formatter.stringFromDate(endDate!)
        self.dateLabel!.text = startDateString + " - " + endDateString
        // --------------------------------------------------
        
        self.descriptionLabel!.text = event!["desc"] as? String
        self.descriptionLabel!.sizeToFit()
        
        self.locationLabel!.text = event!["location"] as? String
        self.titleLabel!.text = event!["title"] as? String
        print("Title: \(titleLabel?.text)")
        titleLabel?.sizeToFit()
        self.coverPhotoView?.file = event!["cover_image"] as? PFFile
        coverPhotoView?.loadInBackground()
        
        let host = event!["host"] as? PFUser
        
        hostProfileView!.layer.masksToBounds = false
        hostProfileView!.layer.cornerRadius = hostProfileView!.frame.size.width / 2
        hostProfileView!.clipsToBounds = true
        
        hostProfileView?.file = host!["orgProfile"] as? PFFile
        hostProfileView?.loadInBackground()
        
        hostNameLabel!.text = host!["name"] as? String
        
        
        let address: String = event!["location"] as! String
        let geocoder: CLGeocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count > 0) {
                let topResult: CLPlacemark = (placemarks?[0])!
                let initialLocation = topResult.location!
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
                    regionRadius * 2.0, regionRadius * 2.0)
                self.addPin(initialLocation)
                self.mapView!.setRegion(coordinateRegion, animated: true)
            }
        })
        
        addTags(event!["tags"] as! [String])
        
        if PFUser.currentUser()!["userType"] as! String == "Organization" {
            joinButton?.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.8)
            joinButton?.setTitle("Organizations cannot join an event", forState: UIControlState.Normal)
            joinButton!.enabled = false
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func openMap(sender: AnyObject) {
        let geoLocation = self.event!["geoLocation"] as! PFGeoPoint
        
        let latitute:CLLocationDegrees = geoLocation.latitude
        let longitute:CLLocationDegrees =  geoLocation.longitude
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.event!["location"])"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    override func viewDidLayoutSubviews() {
        let volunteers = event!["attending"] as! [PFUser]
        print("volunteersCount: \(String(volunteers.count))")
        if volunteers.count == 0 {
            horizontalScrollViewWidth.constant = 45
        } else {
            let additionalWidth = CGFloat(50 * (volunteers.count - 1))
            horizontalScrollViewWidth.constant = 45 + additionalWidth
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
            scrollView.setContentOffset(CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - scrollView.frame.size.height), animated: true)
        }
    }
    
    
    func addTags(tags: [String]) {
        let titlePoint = titleLabel!.frame.origin
        var startPoint = CGPoint(x: titlePoint.x, y: titlePoint.y + 37)
        for tag in tags {
            let tagLabel = UILabel()
            tagLabel.text = textForTag(tag)
            tagLabel.font = UIFont.boldSystemFontOfSize(10)
            tagLabel.frame.origin = startPoint
//            tagLabel.frame.size = CGSize(width: 100, height: 20)
            tagLabel.sizeToFit()
            tagLabel.frame.size.height += 10
            tagLabel.backgroundColor = Constant.themeColor.colorWithAlphaComponent(0.8)
            tagLabel.textColor = UIColor.whiteColor()
            tagLabel.layer.zPosition = 100
            tagLabel.clipsToBounds = true
            tagLabel.layer.cornerRadius = tagLabel.frame.size.height / 2
            scrollView.addSubview(tagLabel)
            startPoint.x += (tagLabel.frame.width + 5)
        }
    }
    
    func textForTag(tag: String) -> String {
        switch tag {
        case "Construction":
            return "   CONSTRUCTION   "
        case "Education":
            return "   EDUCATION   "
        case "Environment":
            return "   ENVIRONMENT   "
        case "Health":
            return "   HEALTH   "
        case "Nutrition":
            return "   NUTRITION   "
        default:
            return tag
        }
    }
    
    func updateAfterJoin() {
        //update button
        let startDate = event!["startDate"] as? NSDate
        if (startDate?.compare(NSDate()) == NSComparisonResult.OrderedAscending) {
            joinButton?.setTitle("Event has passed", forState: UIControlState.Normal)
            joinButton!.enabled = false
        } else if (joined) {
            joinButton?.setTitle("Leave event", forState: UIControlState.Normal)
        } else {
            joinButton?.setTitle("Join event", forState: UIControlState.Normal)
        }
        
        //remove all current items from horizontalScrollView
        horizontalScrollView.subviews.forEach { (view: UIView) in
            view.removeFromSuperview()
        }
        
        //repopulate horizontalScrollView
        let volunteers = event!["attending"] as! [PFUser]
        print(volunteers)
        
        for volunteer in volunteers {
            if volunteer.objectId == PFUser.currentUser()?.objectId {
                joined = true
            }
        }
        
        horizontalScrollView.setItemsMarginOnce()
        var buttonX: CGFloat = 0
        viewDidLayoutSubviews()
        if volunteers.count != 0 {
            noneView.hidden = true
            for (index, volunteer) in volunteers.enumerate() {
                let button = UIButton()
                //button.backgroundColor = UIColor.blueColor()
                
                Alamofire.request(.GET, volunteer["profilePicture"] as! String).response{ (request, response, data, error) in
                    button.setImage(UIImage(data: data!, scale: 1)
                        , forState: UIControlState.Normal)
                    button.setTitle(String(index), forState: UIControlState.Normal)
                    button.frame = CGRectMake(buttonX, 0, 45, 45)
                    buttonX += 50
                    button.layer.masksToBounds = false
                    button.clipsToBounds = true
                    button.layer.cornerRadius = button.frame.size.width / 2
                    button.addTarget(self, action: #selector(self.segueToUserProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                }
                horizontalScrollView.addItem(button)
            }
        } else {
            noneView.hidden = false
            noneView.layer.masksToBounds = false
            noneView.clipsToBounds = true
            noneView.layer.cornerRadius = noneView.frame.size.width / 2
        }
    }
    
    func segueToUserProfile(button: UIButton) {
        self.performSegueWithIdentifier("eventDetailToUserProfileSegue", sender: button)
    }
    
    func addPin(location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView!.addAnnotation(annotation)
    }
    
    func refreshEvent() {
        let eventId = event?.objectId
        let query = PFQuery(className: "Event", predicate: NSPredicate(format: "objectId = '\(eventId)'"))
        query.includeKey("host")
        query.includeKey("attending")
        
        query.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
            if let eventsNotNil = events {
                self.event = eventsNotNil[0]
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        
        var attending = event!["attending"] as! [PFUser]
        
        if joined {
            let alertController = UIAlertController(title: "Are you sure?", message: "You will be removed from this event.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                
            }
            alertController.addAction(cancelAction)
            
            let leaveAction = UIAlertAction(title: "Leave event", style: .Destructive) { (action) in
                let currentId = PFUser.currentUser()?.objectId
                for (index, attendee) in attending.enumerate() {
                    if attendee.objectId == currentId {
                        attending.removeAtIndex(index)
                    }
                }
                self.event?.setObject(attending, forKey: "attending")
                self.event?.saveInBackgroundWithBlock({ (succes: Bool, error: NSError?) in
                    if error == nil {
                        print("Left event")
                        // --------------------------------------------------------------------------------
                        // code to erase an activity when you leave an event.
                        let query = PFQuery(className: "Activity")
                        query.findObjectsInBackgroundWithBlock({ ( objects: [PFObject]?, error: NSError?) in
                            for object in objects! {
                                
                                print(object["user"])
                                print(PFUser.currentUser()!.username!)
                                
                                let activityName = object["activity_name"] as? String
                                let titleLabelText = self.titleLabel!.text!
                                let objectUser = object["user"] as! String
                                let currentUserName = PFUser.currentUser()!["name"] as! String
                                
                                if (activityName == titleLabelText && objectUser == currentUserName) {
                                object.deleteInBackground()
                                }
                            }
                        })
                        // --------------------------------------------------------------------------------
                        
                    } else {
                        print("error: \(error?.localizedDescription)")
                    }
                })
                let leftController = UIAlertController(title: "Done.", message: "You've left this event.", preferredStyle: .Alert)
                self.presentViewController(leftController, animated: true, completion: {
                    leftController.view.superview?.userInteractionEnabled = true
                    leftController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
                })
                self.refreshEvent()
                self.joined = false
                self.viewDidLoad()
                self.updateAfterJoin()
                print("HERE")
                print(self.event!["attending"])
            }
            alertController.addAction(leaveAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        } else {
            
            // code to join
            
            // ----------------------------------------------------------------------------------------------------
            // only create an activity when someone joins.
            let host = event!["host"] as? PFUser
            let userID = PFUser.currentUser()!["id"] as! String
            let name = PFUser.currentUser()!["name"] as! String
            let imageURL = "https://graph.facebook.com/\(userID)/picture?type=large&return_ssl_resources=1"
            Activity.postActivity("joinedEvent", username: name, userFBID: userID, activity_name: titleLabel!.text, imageURL: imageURL, orgID: host!.objectId, withCompletion: nil)
            // ----------------------------------------------------------------------------------------------------
            
            attending.append(PFUser.currentUser()!)
            event?.setObject(attending, forKey: "attending")
            event?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if error == nil {
                    self.performSegueWithIdentifier("eventDetailToJoinedSegue", sender: nil)
                } else {
                    print("error: \(error?.localizedDescription)")
                }
            })
            self.refreshEvent()
            self.joined = true
            //viewDidLoad()
            self.updateAfterJoin()
        }
    }
    
    @IBAction func addToCalendar(sender: AnyObject) {
        let store = EKEventStore()
        store.requestAccessToEntityType(EKEntityType.Event) { (success: Bool, error: NSError?) in
            if success {
                print("YAY")
                let calendarEvent = EKEvent(eventStore: store)
                calendarEvent.title = self.event!["title"] as! String
                calendarEvent.startDate = self.event!["startDate"] as! NSDate
                calendarEvent.endDate = self.event!["endDate"] as! NSDate
                calendarEvent.calendar = store.defaultCalendarForNewEvents
                calendarEvent.notes = self.event!["desc"] as? String
                calendarEvent.location = self.event!["location"] as? String
                do {
                    try store.saveEvent(calendarEvent, span: EKSpan.ThisEvent)
                    let createdController = UIAlertController(title: "Done.", message: "This event was added to your calendar.", preferredStyle: .Alert)
                    self.presentViewController(createdController, animated: true, completion: {
                        createdController.view.superview?.userInteractionEnabled = true
                        createdController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
                    })
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "eventDetailToJoinedSegue") {
            let destinationVC = segue.destinationViewController as! JoinedViewController
            destinationVC.event = self.event
            destinationVC.imageFile = coverPhotoView?.file
        } else if (segue.identifier == "eventDetailToOrgProfileSegue") {
            //let destinationNavigationController = segue.destinationViewController as! UINavigationController
            //let destinationVC = destinationNavigationController.topViewController as! OrgProfileViewController
            let destinationVC = segue.destinationViewController as! OrgProfileViewController
            print(self.event!["host"] as? PFUser)
            destinationVC.user = self.event!["host"] as? PFUser 
        } else if (segue.identifier == "eventDetailToUserProfileSegue") {
            let button = sender as! UIButton
            let destinationVC = segue.destinationViewController as! UserProfileViewController
            let attending = event!["attending"] as! [PFUser]
            let user = attending[Int(button.currentTitle!)!]
            destinationVC.user = user
            
//            let query = PFQuery(className: "_User")
//            query.whereKey("name", equalTo: button.currentTitle!)
//            
//            query.findObjectsInBackgroundWithBlock { (volunteers: [PFObject]?, error: NSError?) -> Void in
//                if error == nil {
//                    if volunteers!.count != 0 {
//                        user = volunteers![0] as? PFUser
//                        destinationVC.user = user
//                    }
//                } else {
//                    print(error?.localizedDescription)
//                }
//            }
            destinationVC.profilePhoto = button.imageView!.image
        }
    }
    
    @IBAction func orgProfileButtonClicked(sender: AnyObject) {
        performSegueWithIdentifier("eventDetailToOrgProfileSegue", sender: sender)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
