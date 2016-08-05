//
//  OrgProfileViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/12/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class OrgProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, KMSegmentedControlDelegate {
    
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var subscribeButton: UIButton!
    
    @IBOutlet weak var numCurrentLabel: UILabel!
    @IBOutlet weak var numPastLabel: UILabel!
    
    var currentEvents = [PFObject]?()
    var historyEvents = [PFObject]?()
    var queryLimit: Int = 10
    var isCurrent: Bool = true
    var userLocation: CLLocation?
    var user: PFUser?
    let currentUser = PFUser.currentUser()
    let locationManager = CLLocationManager()
    let refreshControl = UIRefreshControl()
    var alreadySubscribed: Bool = false
    
    var didQueryCurrent: Bool = false
    var didQueryHistory: Bool = false
    
    //@IBOutlet weak var numEventsLabel: UILabel!
    //@IBOutlet weak var numSubscribersLabel: UILabel!
    
    @IBOutlet weak var kmSegmentedControl: KMSegmentedControl!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        kmSegmentedControl.delegate = self
        
        kmSegmentedControl.items = ["CURRENT EVENTS", "PAST EVENTS"]
        
        kmSegmentedControl.KMSelectorLineColor = Constant.themeColor
        kmSegmentedControl.KMUnSelectedTitleColor = UIColor.blackColor()
        kmSegmentedControl.KMSelectedTitleColor = Constant.themeColor
        kmSegmentedControl.KMFontSize = 12
        
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        kmSegmentedControl.KMBackgroundColor = self.view.backgroundColor
        
        //numEventsLabel.text = ""
        //numSubscribersLabel.text = ""
        
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        subscribeButton.backgroundColor = UIColor.whiteColor()
        subscribeButton.layer.cornerRadius = subscribeButton.frame.size.height / 2
        subscribeButton.layer.borderWidth = 1
        subscribeButton.layer.borderColor = Constant.themeColor.CGColor
        subscribeButton.clipsToBounds = true
        
        numCurrentLabel.text = ""
        numPastLabel.text = ""
        
        if currentUser!["userType"] as! String == "Organization" {
            subscribeButton.enabled = false
            subscribeButton.hidden = true
            logoutButton = nil
            self.user = currentUser
        }
        else {
            let subscribed = PFUser.currentUser()!["subscribed"] as! [PFUser]
            for subscribee in subscribed {
                print("subscribee: \(subscribee)")
                print("thisOrg: \(self.user)")
                if subscribee.objectId == user!.objectId {
                    alreadySubscribed = true
                }
            }
            if alreadySubscribed {
              subscribeButton.setTitle("FOLLOWING", forState: UIControlState.Normal)
            } else {
                subscribeButton.setTitle("FOLLOW", forState: UIControlState.Normal)
            }
            numCurrentLabel.hidden = true
            numPastLabel.hidden = true
        }
        refreshControlAction(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }  // end of viewDidLoad
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
        
        nameLabel.text = user!["name"].description
        
        tableView.dataSource = self
        tableView.delegate = self
        
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        
        // load currentEvents and historyEvents
        fetchEvents()
        
        self.profileImageView.file = user!["orgProfile"] as? PFFile
        self.profileImageView.loadInBackground()
        
        // tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    // for KMSegmentedControl
    
    func didSelect(selected item: UIButton) {
        if item.titleLabel!.text == "CURRENT EVENTS" {
            isCurrent = true
            fetchEvents()
        } else {
            isCurrent = false
            fetchEvents()
        }
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    func fetchEvents(){
        // query.limit = 20
        
        //currentDateTime is 7 hours ahead, different time zone?
        let currentDateTime = NSDate()
        
        print(currentDateTime)
        // if isCurrent {
            let currentQuery = PFQuery(className: "Event")
            currentQuery.includeKey("host")
            currentQuery.includeKey("attending")
            currentQuery.whereKey("startDate", greaterThan: currentDateTime)
            currentQuery.whereKey("host", equalTo: self.user!)
            // currentQuery.whereKey("date", lessThan: AnyObject)
            currentQuery.orderByAscending("startDate")
            currentQuery.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
                if let eventsNotNil = events {
                    self.currentEvents = eventsNotNil
                    self.numCurrentLabel.text = String(eventsNotNil.count)
                } else {
                    print(error?.localizedDescription)
                }
                if self.didQueryHistory {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.didQueryHistory = false
                } else {
                    self.didQueryCurrent = true
                }
            }
        // } else {
            let historyQuery = PFQuery(className: "Event")
            historyQuery.includeKey("host")
            historyQuery.includeKey("attending")
            historyQuery.whereKey("startDate", lessThan: currentDateTime)
            historyQuery.whereKey("host", equalTo: self.user!)
            historyQuery.orderByAscending("endDate")
            historyQuery.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
                if let eventsNotNil = events {
                    self.historyEvents = eventsNotNil
                    self.numPastLabel.text = String(eventsNotNil.count)
                } else {
                    print(error?.localizedDescription)
                }
                if self.didQueryCurrent {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.didQueryCurrent = false
                } else {
                    self.didQueryHistory = true
                }
            }
        
        // }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        PFUser.logOut()
        let Login = storyboard!.instantiateViewControllerWithIdentifier("SplashPageViewController")
        self.presentViewController(Login, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCurrent && currentEvents != nil {
            return currentEvents!.count
        } else if historyEvents != nil {
            return historyEvents!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrgEventsCell", forIndexPath: indexPath) as! OrgEventsCell
        //cell.currentLocation = self.userLocation
        if isCurrent {
            cell.event = currentEvents![indexPath.row]
        } else {
            cell.event = historyEvents![indexPath.row]
        }
        cell.delegate = self
        return cell
    }
    
    func deletedEvent() {
        let leftController = UIAlertController(title: "Done.", message: "Your event has been deleted.", preferredStyle: .Alert)
        self.presentViewController(leftController, animated: true, completion: {
            leftController.view.superview?.userInteractionEnabled = true
            leftController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    func alertControllerBackgroundTapped()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.refreshControlAction(refreshControl)
    }
    
    @IBAction func subscribeButtonClicked(sender: UIButton) {
       var subscribed = self.currentUser!["subscribed"] as! [PFUser]
        if alreadySubscribed {
            // --------------------------------------------------------------------------------
            // code to unsubscribe a user that is already subscribed.
            let alertController = UIAlertController(title: "Are you sure?", message: "You will not be notified of any new events.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            }
            alertController.addAction(cancelAction)
            let unsubAction = UIAlertAction(title: "UNFOLLOW", style: .Destructive) { (action) in
                var newSubscribed = [PFUser]()
                for subscriber in subscribed {
                    if subscriber.objectId != self.user!.objectId {
                        newSubscribed.append(subscriber)
                    }
                }
                self.currentUser?.setObject(newSubscribed, forKey: "subscribed")
            self.currentUser?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                if error == nil {
                    // --------------------------------------------------------------------------------
                    // code to erase the activity when you desub
                    let query = PFQuery(className: "Activity")
                    query.findObjectsInBackgroundWithBlock({ ( objects: [PFObject]?, error: NSError?) in
                        for object in objects! {
                            
                            let activityName = object["activity_name"] as? String
                            let titleLabelText = self.nameLabel!.text!
                            let objectUser = object["user"] as! String
                            let currentUserName = PFUser.currentUser()!["name"] as! String
                            
                            if (activityName == titleLabelText && objectUser == currentUserName) {
                                object.deleteInBackground()
                            }
                        }
                    })
                    // --------------------------------------------------------------------------------
                    self.subscribeButton.setTitle("FOLLOW", forState: UIControlState.Normal)
                } else {
                    print("error: \(error?.localizedDescription)")
                }
            })
                
            } // end of unsub action
            alertController.addAction(unsubAction)
            self.presentViewController(alertController, animated: true) {}
            self.alreadySubscribed = false
            
        } else {
            // code to join
            subscribed.append(self.user!)
            self.currentUser?.setObject(subscribed, forKey: "subscribed")
            self.currentUser?.saveInBackgroundWithBlock({ (succes: Bool, error: NSError?) in
                if error == nil {
                    // --------------------------------------------------------------------------------
                    // only make an activity if you're subscribing.
                    let userID = PFUser.currentUser()!["id"] as! String
                    let name = PFUser.currentUser()!["name"] as? String
                    let imageURL = "https://graph.facebook.com/\(userID)/picture?type=large&return_ssl_resources=1"
                    Activity.postActivity("followedOrg", username: name, userFBID: userID, activity_name: self.nameLabel.text, imageURL: imageURL, orgID: self.user?.objectId, withCompletion: nil)
                    // --------------------------------------------------------------------------------
                    self.subscribeButton.setTitle("UNFOLLOW", forState: UIControlState.Normal)
                } else {
                    print("error: \(error?.localizedDescription)")
                }
            })
            self.alreadySubscribed = true
        } // end of alreadySubscribed = false case
    } // end of subscription button action
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "orgProfileToCreateEventSegue" {
            let cell = sender as! OrgEventsCell
            let destinationVC = segue.destinationViewController as! CreateEventViewController
            destinationVC.editingEvent = cell.event
        } else if segue.identifier == "orgProfileToEventDetailSegue" {
            let cell = sender as! OrgEventsCell
            let destinationVC = segue.destinationViewController as! EventDetailViewController
            destinationVC.event = cell.event
        }
    }
    
} // end of OrgProfile Class