//
//  NearbyViewController.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import CoreLocation
import HidingNavigationBar
//import PeekPop
import Darwin

class NearbyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, HidingNavigationBarManagerDelegate {
    
    var hidingNavBarManager: HidingNavigationBarManager?

    @IBOutlet weak var tableView: UITableView!
    var events: [PFObject] = []
    var tempEvents: [(PFObject, Int)] = []
    let query = PFQuery(className: "Event")
    var refreshControl = UIRefreshControl()
    //var modEvents = [modEvent]?()
    var userLocation: PFGeoPoint?
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var segmentedBar: UISegmentedControl!
    
    var navBarHidden = false
    
    var radius = 25
    var distance: String?
    
    var isDistance = true
    var isDuration = false
    var isSubscribed = false
    var isDate = false
    
    var tableViewHeight: CGFloat?
    var tableViewX: CGFloat?
    var tableViewY: CGFloat?
    var tableViewWidth: CGFloat?
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderLabel: UILabel!
    
    @IBOutlet weak var subscribedButton: UIButton!
    
    @IBOutlet weak var dropDownView: UIView!
    
    @IBOutlet weak var advSegmentedControl: ADVSegmentedControl!
    
    @IBOutlet weak var dropDownBackground: UIView!
    
    var isAnimating: Bool = false
    var dropDownViewIsDisplayed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableViewHeight = self.tableView.frame.height
        self.tableViewWidth = self.tableView.frame.width
        self.tableViewX = self.tableView.frame.origin.x
        self.tableViewY = self.tableView.frame.origin.y
        
        dropDownBackground.layer.borderWidth = 3
        dropDownBackground.layer.borderColor = Constant.themeColor.CGColor
        dropDownBackground.layer.cornerRadius = 7
        dropDownBackground.layer.masksToBounds = true
        
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = 250

        let height = self.dropDownView.frame.size.height
        let width = self.dropDownView.frame.size.width
        self.dropDownView.frame = CGRectMake(0, -height, width, height)
        self.dropDownViewIsDisplayed = true
        
         self.tableView.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.size.height + 24, self.view.frame.size.width, 600)
        
        //hidingNavBarManager?.addExtensionView(topView)
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
        hidingNavBarManager?.refreshControl = refreshControl
        //hidingNavBarManager?.expansionResistance = 150
        //hidingNavBarManager?.addExtensionView(extensionView)
        //hidingNavBarManager?.addExtensionView(tableView)
        //navigationController?.hidesBarsOnSwipe = true
        
        let image = UIImage(named: "textlogowhite (3)")
        navigationItem.titleView = UIImageView(image: image)
        
        /*let buttonArray = [distanceButton, dateButton, durationButton, subscribedButton]
        
        for item in buttonArray {
            let button = item
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 3
            button.layer.borderColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0).CGColor
        }*/
        
        //sliderLabel.textColor = UIColor.whiteColor()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
            
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
            // locationManager.requestLocation()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        hidingNavBarManager?.delegate = self
        
        refreshControl.addTarget(self, action: #selector (refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControlAction(refreshControl)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
    }
    
    @IBAction func filterButtonClicked(sender: AnyObject) {
        print(self.dropDownViewIsDisplayed)
        if (self.dropDownViewIsDisplayed) {
            self.hideDropDownView()
        } else {
            self.showDropDownView()
        }
    }
    
    func hideDropDownView() {
        var frame = self.dropDownView.frame
        frame.origin.y = -frame.size.height
        print(frame.size.height)
        self.animateDropDownToFrame(frame)
        self.dropDownViewIsDisplayed = false
    }
    
    func showDropDownView() {
        var frame = self.dropDownView.frame
        frame.origin.y = self.navigationController!.navigationBar.frame.size.height + 24
        self.animateDropDownToFrame(frame)
        self.dropDownViewIsDisplayed = true
    }
    
    func animateDropDownToFrame(frame: CGRect) {
        if (!self.isAnimating) {
            self.isAnimating = true
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.dropDownView.frame = frame
                
                if self.dropDownViewIsDisplayed {
                    
                    //self.tableView.frame = CGRectMake(self.tableViewX!, 0, self.tableViewWidth!, self.tableViewHeight!)
                    
                    var yPoint : CGFloat
                    
                    if self.navBarHidden {
                        yPoint = self.navigationController!.navigationBar.frame.size.height - 24
                    }
                    else {
                        yPoint = self.navigationController!.navigationBar.frame.size.height + 24
                    }
                    
                    self.tableView.frame = CGRectMake(0, yPoint, self.view.frame.size.width, 600)
                    //self.tableView.frame.origin.y = self.navigationController!.navigationBar.frame.size.height + 19
                }
                else {
                    //self.tableView.frame = CGRectMake(0,212, 375, 406)
                    
                     self.tableView.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.size.height + self.dropDownView.frame.height + 24, self.view.frame.size.width, 600)
                    //self.tableView.frame.origin.y = self.navigationController!.navigationBar.frame.size.height + self.dropDownView.frame.height + 19
                }
            })
            self.isAnimating = false
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        hidingNavBarManager?.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        hidingNavBarManager?.viewWillDisappear(animated)
         //self.hideDropDownView()
        
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        
        return true
    }
    
    /*func scrollViewDidScroll(scrollView: UIScrollView) {
        dropDownViewIsDisplayed = true
        hideDropDownView()
        
    }*/
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0)
        {
            navBarHidden = false
            
            if (self.dropDownViewIsDisplayed) {
                //self.showDropDownView()
                //self.hideDropDownView()
            } else {
                 self.tableView.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.size.height + 24, self.view.frame.size.width, 600)
                //self.showDropDownView()
            }
        }
        else
        {
            dropDownViewIsDisplayed = true
            hideDropDownView()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userLocation = PFGeoPoint(location: locations[0])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if self.events != nil {
            return self.events.count
        //return 1
       //}
        //return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NearbyCell", forIndexPath: indexPath) as! NearbyCell
        let event = events[indexPath.row]
        cell.currentLocation = self.userLocation
        
        cell.event = event
        
        return cell
    }
    
    func hidingNavigationBarManagerDidChangeState(manager: HidingNavigationBarManager, toState state: HidingNavigationBarState) {
        if state == HidingNavigationBarState.Open {
            navBarHidden = false
        }
        else {
            navBarHidden = true
        }
    }
    
    func hidingNavigationBarManagerDidUpdateScrollViewInsets(manager: HidingNavigationBarManager) {
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.identifier)
        
        if (segue.identifier == "nearbyCellToEventDetailSegue") {
            let cell = sender as! NearbyCell
            let indexPath = tableView.indexPathForCell(cell)
              tableView.deselectRowAtIndexPath(indexPath!, animated:true)
            let destinationVC = segue.destinationViewController as! EventDetailViewController
            destinationVC.event = cell.event
            //destinationVC.passEvent(cell.event!)
            //will need to modify eventdetail view so that event is of type pfobject
        }
     

    }
    
    
    func fetchEvents(){
        //currentDateTime is 7 hours ahead, different time zone?
        let currentDateTime = NSDate()
        
        query.whereKey("startDate", greaterThan: currentDateTime)
        query.limit = 20
        
        var user = PFUser.currentUser()
//        print(user)
//        do {
//            try user?.fetch()
//        } catch {
//            print("sad")
//        }
//        user!.fetchInBackground()
        user!.fetchInBackgroundWithBlock { (completeUser: PFObject?, error: NSError?) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print(completeUser)
                user = completeUser as? PFUser
                self.processEvents(user!)
            }
        }
    }
    
    func processEvents(user: PFUser) {
        let subscribed = user["subscribed"] as! [PFUser]
        var subObjIds : [String] = []
        var subOrg : [PFUser] = []
        
        for org in subscribed {
            //subObjIds.append(org.objectId!)
            subOrg.append(org)
        }
        
        if self.isDuration {
            query.orderByAscending("duration")
        } else if self.isDate {
            query.orderByAscending("startDate")
        }
        
        query.includeKey("host")
        query.includeKey("attending")
        //        query.includeKey("tags")
        
        if self.isSubscribed {
            query.whereKey("host", containedIn: subOrg)
        }
        
        query.findObjectsInBackgroundWithBlock { (events: [PFObject]?, error: NSError?) -> Void in
            if let eventsNotNil = events {
                //self.events = eventsNotNil
                
                self.events = []
                self.tempEvents = []
                
                for event in eventsNotNil {
                    let eventLocation = event["geoLocation"] as! PFGeoPoint
                    print("LOCATION INFO")
                    print(eventLocation)
                    print(self.userLocation)
                    let distance = Int(eventLocation.distanceInMilesTo(self.userLocation))
                    if distance < self.radius{
                        if self.isDistance {
                            self.tempEvents.append((event, distance))
                        }
                        /*else if self.isSubscribed {
                            let host = event["host"] as! PFUser
                            print(subscribed)
                            print(host)
                            if subObjIds.contains(host.objectId!) {
                                self.events.append(event)
                            }
                        }*/
                        else {
                            self.events.append(event)
                        }
                        self.distance = Constant.newDistanceToMilesAway(distance)
                    }
                }
                
                if self.isDistance {
                    self.tempEvents.sortInPlace{ $0.1 < $1.1 }
                    for (l,k) in self.tempEvents {
                        self.events.append(l)
                    }
                }
                
            } else {
                print(error?.localizedDescription)
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        fetchEvents()
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        //radius = currentValue
        sliderLabel.text = String(currentValue)
        //fetchEvents()
    }
    
    @IBAction func releaseControl(sender: UISlider) {
        let currentValue = Int(sender.value)
        self.radius = currentValue
        refreshControlAction(refreshControl)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func indexChanged(sender: AnyObject) {
        if advSegmentedControl.selectedIndex == 0 {
            isDistance = true
            isDuration = false
            isDate = false
            
            //NSThread.sleepForTimeInterval(0.5)
            refreshControlAction(refreshControl)
        } else if advSegmentedControl.selectedIndex == 1 {
            isDistance = false
            isDuration = false
            //isSubscribed = false
            isDate = true
            
            //NSThread.sleepForTimeInterval(0.5)
            refreshControlAction(refreshControl)
        }
        else {
            isDistance = false
            isDuration = true
            //isSubscribed = false
            isDate = false
            
            //NSThread.sleepForTimeInterval(0.05)
            refreshControlAction(refreshControl)
        }
    }
    

    
    @IBAction func subscribedButtonClicked(sender: UIButton) {
        /*sender.setImage(UIImage(named: "checkmark"), forState: UIControlState.Normal)
        distanceButton.setImage(nil, forState: UIControlState.Normal)
        dateButton.setImage(nil, forState: UIControlState.Normal)
        durationButton.setImage(nil, forState: UIControlState.Normal)
        isDistance = false
        isDuration = false*/
        
        if sender.currentTitle == "Only Show Subscribed Events" {
            isSubscribed = false
            sender.setTitle("Only Showing Subscribed Events", forState: UIControlState.Normal)
            
            //sender.titleLabel!.text = "Only Showing Subscribed Events"
            
        }
        else {
            isSubscribed = true
            sender.setTitle("Only Show Subscribed Events", forState: UIControlState.Normal)
        }
        //isDate = false
        refreshControlAction(refreshControl)
    }

}
