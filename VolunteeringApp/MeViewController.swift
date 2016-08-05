//
//  MeViewController.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Alamofire
import ImageLoader
import ASHorizontalScrollView
import Twinkle
import PrettyTimestamp
import KMSegmentedControl

class MeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, KMSegmentedControlDelegate {
    
    // Use alamofire to display user profile picture

    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var followingTableView: UITableView!
    
    //@IBOutlet weak var advSegmentedControl: ADVSegmentedControl!
    
    var currentEvents = [PFObject]?()
    var historyEvents = [PFObject]?()
    var followingOrgs = [PFUser]?()
    var queryLimit: Int = 10
    var isCurrent: Bool = true
    var userLocation: CLLocation?
    var user = PFUser.currentUser()
    let locationManager = CLLocationManager()
    let refreshControl = UIRefreshControl()
    let refreshControl2 = UIRefreshControl()
    
    @IBOutlet weak var historyEventsLabel: UILabel!
    @IBOutlet weak var currentEventsLabel: UILabel!
    
    var didQueryCurrent: Bool = false
    var didQueryHistory: Bool = false
    var didQueryFollowing: Bool = false
    
    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var achievementLabel: UILabel!
    
    
    var firstFetch = true
    
    //@IBOutlet weak var numEventsLabel: UILabel!
    @IBOutlet weak var numHoursLabel: UILabel!
    
    @IBOutlet weak var trophyButton: UIButton!
    
    var unchecked = false
     var existingAchievements: [Int] = []
    var achievements: [String] = []
    
    @IBOutlet var kmSegmentedControl: KMSegmentedControl!
    
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = ""
        subscriptionLabel.text = ""
        historyEventsLabel.text = ""
        currentEventsLabel.text = ""
        subscriptionLabel.text = ""
        achievementLabel.text = ""
        numHoursLabel.text = ""
        
        tableView.dataSource = self
        tableView.delegate = self
        
        followingTableView.dataSource = self
        followingTableView.delegate = self
        
        //advSegmentedControl.items = ["Current Events", "History Events", "Subscriptions"]
        //advSegmentedControl.font = UIFont(name: "Avenir-Black", size: 10)
        
        kmSegmentedControl.delegate = self
        
        kmSegmentedControl.items = ["CURRENT EVENTS", "PAST EVENTS", "FOLLOWING"]
        
        kmSegmentedControl.KMSelectorLineColor = Constant.themeColor
        kmSegmentedControl.KMUnSelectedTitleColor = UIColor.blackColor()
        kmSegmentedControl.KMSelectedTitleColor = Constant.themeColor
        kmSegmentedControl.KMFontSize = 12
        //kmSegmentedControl.KMSelectedItemColor = UIColor.whiteColor()
        
        
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        // ----------------------------------------------------------------------------
        // display subscription count in the label
        let subscribedCount = PFUser.currentUser()!["subscribed"] as! NSArray
        subscriptionLabel.text = subscribedCount.count.description
        // ----------------------------------------------------------------------------
        print(user)
        
        self.subscriptionLabel.text = String(user!["subscribed"].count)
        //segmentedControl.setTitle(String(user!["subscribed"].count) + " Subscriptions", forSegmentAtIndex: 2)
        //advSegmentedControl.items = ["Current Events", "History Events", String(user!["subscribed"].count) + " Subscriptionsssss"]
        
        let achievements = user!["achievements"] as! [String]
        self.achievementLabel.text = String(achievements.count)
        
        self.achievements = achievements
        for achievement in achievements {
            if !Constant.extractBool(achievement) {
                self.unchecked = true
            }
        }
        
        for achievement in achievements {
            existingAchievements.append(Constant.extractInt(achievement))
        }
        
        if unchecked {
            UIView.animateWithDuration(0.6 ,
                                       animations: {
                                        self.trophyButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                },
                                       completion: { finish in
                                        UIView.animateWithDuration(0.6){
                                            self.trophyButton.transform = CGAffineTransformIdentity
                                        }
            })
            
            trophyButton.twinkle()
            trophyButton.setImage(UIImage(named:"gold-trophy"), forState: UIControlState.Normal)
        }

        /*levelView.layer.cornerRadius = levelView.frame.size.width/2
        levelView.clipsToBounds = true */
        
        nameLabel.text = user!["name"].description
        //self.navigationController?.navigationBar.topItem?.title = user?["name"].description
        
        profilePhotoView.layer.masksToBounds = false
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.size.width/2
        profilePhotoView.clipsToBounds = true
        //self.profilePhotoView.layer.borderWidth = 4
        self.profilePhotoView.layer.borderColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0).CGColor // theme color
        
        refreshControlAction(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl2.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        followingTableView.insertSubview(refreshControl2, atIndex: 0)
        
        Alamofire.request(.GET, user!["profilePicture"] as! String).response { (request, response, data, error) in
            self.profilePhotoView.image = UIImage(data: data!, scale: 1)
        }
    }

    // ----------------------------------------------------------------------------------------------------------------------------
    
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
        
        // load currentEvents and historyEvents
        fetchEvents()
        
        self.refreshControl.endRefreshing()
        self.refreshControl2.endRefreshing()
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------

    func didSelect(selected item: UIButton) {
        if item.titleLabel!.text == "CURRENT EVENTS" {
            tableView.hidden = false
            isCurrent = true
            tableView.reloadData()
        } else if item.titleLabel!.text == "PAST EVENTS" {
            tableView.hidden = false
            isCurrent = false
            if firstFetch {
                fetchEvents()
                firstFetch = false
            }
            else {
                tableView.reloadData()
            }
        } else {
            tableView.hidden = true
            followingTableView.reloadData()
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
            currentQuery.whereKey("attending", containsAllObjectsInArray: [self.user!])
            // currentQuery.whereKey("date", lessThan: AnyObject)
            currentQuery.orderByAscending("startDate")
            currentQuery.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
                if let eventsNotNil = events {
                    self.currentEventsLabel.text = String(eventsNotNil.count)
                    
                    self.currentEvents = eventsNotNil
                } else {
                    print(error?.localizedDescription)
                }
                if self.didQueryHistory && self.didQueryFollowing {
                    self.tableView.reloadData()
                    self.followingTableView.reloadData()
                    self.didQueryHistory = false
                    self.didQueryFollowing = false
                    self.refreshControl.endRefreshing()
                } else {
                    self.didQueryCurrent = true
                }
            }
        // } else {
            let historyQuery = PFQuery(className: "Event")
            historyQuery.includeKey("host")
            historyQuery.includeKey("attending")
            historyQuery.whereKey("startDate", lessThan: currentDateTime)
            historyQuery.whereKey("attending", containsAllObjectsInArray: [self.user!])
            historyQuery.orderByAscending("endDate")
            historyQuery.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
                if let eventsNotNil = events {
                    self.historyEvents = eventsNotNil

                    self.historyEventsLabel.text = String(eventsNotNil.count)
                    //self.numEventsLabel.text = String(eventsNotNil.count)
                    //self.segmentedControl.setTitle(String(eventsNotNil.count) + " History Events", forSegmentAtIndex: 1)

                    // ----------------------------------------------------------------------------
                    // display subscription count in the label
                    //let subscribedCount = PFUser.currentUser()!["subscribed"] as! NSArray

                    //self.subscriptionLabel.text = subscribedCount.count.description

                    // ----------------------------------------------------------------------------
                    
                    var hours = 0
                    
                    for event in eventsNotNil {
                        hours = hours + (event["duration"] as! Int)
                    }
                    
                    self.numHoursLabel.text = String(hours)
                } else {
                    print(error?.localizedDescription)
                }
                if self.didQueryCurrent && self.didQueryFollowing {
                    self.tableView.reloadData()
                    self.followingTableView.reloadData()
                    self.didQueryCurrent = false
                    self.didQueryFollowing = false
                    self.refreshControl.endRefreshing()
                    self.refreshControl2.endRefreshing()
                } else {
                    self.didQueryHistory = true
                }
        }
        
        user!.fetchInBackgroundWithBlock { (completeUser: PFObject?, error: NSError?) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                self.user = completeUser as? PFUser
                self.followingOrgs = self.user!["subscribed"] as? [PFUser]
                if self.didQueryCurrent && self.didQueryHistory {
                    self.tableView.reloadData()
                    self.followingTableView.reloadData()
                    self.didQueryCurrent = false
                    self.didQueryHistory = false
                    self.refreshControl.endRefreshing()
                    self.refreshControl2.endRefreshing()
                } else {
                    self.didQueryFollowing = true
                }
            }
        }
        
        // }
    }
   
    // ----------------------------------------------------------------------------------------------------------------------------

    @IBAction func trophyButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("userProfileToTrophySegue", sender: sender)
    }

    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations[0]
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.followingTableView {
            let cell = followingTableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowingCell
            cell.organization = followingOrgs![indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MyEventsCell") as! MyEventsCell
            cell.currentLocation = self.userLocation
            if isCurrent {
                cell.event = currentEvents![indexPath.row]
                let replacedString = cell.dateLabel.text!.stringByReplacingOccurrencesOfString("ago", withString: "from now")
                cell.dateLabel.text = replacedString
            } else {
                cell.event = historyEvents![indexPath.row]
            }
            return cell
        }
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.user)
        if tableView == self.followingTableView {
            if followingOrgs != nil {
                return followingOrgs!.count
            } else {
                return 0
            }
        } else {
            if isCurrent && currentEvents != nil {
                return currentEvents!.count
            } else if historyEvents != nil {
                return historyEvents!.count
            } else {
                return 0
            }
        }
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "myEventsCellToEventDetailSegue") {
            print("EVENTS CELL SEGUE")
            let cell = sender as! MyEventsCell
            let indexPath = tableView.indexPathForCell(cell)
            tableView.deselectRowAtIndexPath(indexPath!, animated:true)
            let destinationVC = segue.destinationViewController as! EventDetailViewController
            destinationVC.event = cell.event
        } else if(segue.identifier == "userProfileToTrophySegue") {
            let destinationVC = segue.destinationViewController as! TrophyViewController
            destinationVC.existingAchievements = self.existingAchievements
            destinationVC.achievements = self.achievements
        } else if (segue.identifier == "followingCellToOrgProfileSegue") {
            let cell = sender as! FollowingCell
            let indexPath = followingTableView.indexPathForCell(cell)
            followingTableView.deselectRowAtIndexPath(indexPath!, animated: true)
            let destinationVC = segue.destinationViewController as! OrgProfileViewController
            destinationVC.user = cell.completeOrganization
        }
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    @IBAction func logoutButtonClicked(sender: AnyObject)
    {
        PFUser.logOut()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let Login = storyboard!.instantiateViewControllerWithIdentifier("SplashPageViewController") 
        self.presentViewController(Login, animated: true, completion: nil)
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------

}