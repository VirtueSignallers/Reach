//
//  UserProfileViewController.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/19/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Alamofire
import ImageLoader
import KMSegmentedControl

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, KMSegmentedControlDelegate {

    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var kmSegmentedControl: KMSegmentedControl!
    
    var currentEvents = [PFObject]()
    var historyEvents = [PFObject]()
    var queryLimit: Int = 10
    var isCurrent: Bool = true
    var profilePhoto: UIImage?
    
    var userLocation: CLLocation?
    var userId: String?
    var user: PFUser?
    
    var didQueryCurrent: Bool = false
    var didQueryHistory: Bool = false
    
    let locationManager = CLLocationManager()
    let refreshControl = UIRefreshControl()
    
    //@IBOutlet weak var numEventsLabel: UILabel!
    @IBOutlet weak var numHoursLabel: UILabel!
    //@IBOutlet weak var levelView: UIView!
    
    @IBOutlet weak var currentEventsLabel: UILabel!
    @IBOutlet weak var historyEventsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        numHoursLabel.text = ""
        currentEventsLabel.text = ""
        historyEventsLabel.text = ""
        
        kmSegmentedControl.delegate = self
        
        kmSegmentedControl.items = ["CURRENT EVENTS", "PAST EVENTS"]
        
        kmSegmentedControl.KMSelectorLineColor = Constant.themeColor
        kmSegmentedControl.KMUnSelectedTitleColor = UIColor.blackColor()
        kmSegmentedControl.KMSelectedTitleColor = Constant.themeColor
        kmSegmentedControl.KMFontSize = 12
        kmSegmentedControl.KMBackgroundColor = self.view.backgroundColor
        
        profilePhotoView.image = profilePhoto
        
        //levelView.layer.cornerRadius = levelView.frame.size.width/2
        //levelView.clipsToBounds = true
        
        refreshControlAction(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

        // Do any additional setup after loading the view.
    }
    
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
        
        nameLabel.text = user?["name"].description
        
        tableView.dataSource = self
        tableView.delegate = self
        
        profilePhotoView.layer.masksToBounds = false
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.size.width/2
        profilePhotoView.clipsToBounds = true
        
        // load currentEvents and historyEvents
        fetchEvents()
        
        self.refreshControl.endRefreshing()
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    func fetchEvents(){
        // query.limit = 20
        
        //currentDateTime is 7 hours ahead, different time zone?
        let currentDateTime = NSDate()
        
        print(currentDateTime)
        //if isCurrent {
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
                print("YAY1\n")
                print("count: \(String(self.currentEvents.count))")
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
        historyQuery.whereKey("attending", containsAllObjectsInArray: [self.user!])
        historyQuery.orderByAscending("endDate")
        historyQuery.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
            if let eventsNotNil = events {
                self.historyEvents = eventsNotNil
                self.historyEventsLabel.text = String(eventsNotNil.count)
                
                var hours = 0
                
                for event in eventsNotNil {
                    hours = hours + (event["duration"] as! Int)
                }
                
                self.numHoursLabel.text = String(hours)
                
                print("YAY2\n")
                print("count: \(String(self.historyEvents.count))")
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
        //}
    }
    
    /*@IBAction func indexChanged(sender: UISegmentedControl) {
        if (segmentedControl.selectedSegmentIndex == 0) {
            isCurrent = true
        } else { // == 1
            print("index changed successful")
            isCurrent = false
        }
        tableView.reloadData()
    }*/
    
    func didSelect(selected item: UIButton) {
        if item.titleLabel!.text == "CURRENT EVENTS" {
            isCurrent = true
            self.tableView.reloadData()
        } else {
            isCurrent = false
            self.tableView.reloadData()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = locations[0]
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserEventsCell") as! MyEventsCell
        cell.currentLocation = self.userLocation
        if isCurrent {
            cell.event = currentEvents[indexPath.row]
        } else {
            print("entered history events")
            cell.event = historyEvents[indexPath.row]
        }
        return cell
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCurrent {
            return currentEvents.count
        } else {
            return historyEvents.count
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "userEventsCellToEventDetailSegue") {
            let cell = sender as! MyEventsCell
            let indexPath = tableView.indexPathForCell(cell)
            tableView.deselectRowAtIndexPath(indexPath!, animated:true)
            let destinationVC = segue.destinationViewController as! EventDetailViewController
            destinationVC.event = cell.event
            //destinationVC.passEvent(cell.event!)
            //will need to modify eventdetail view so that event is of type pfobject
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
