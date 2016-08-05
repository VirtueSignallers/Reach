//
//  OrgActivityViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/15/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class OrgActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let user = PFUser.currentUser()
    var activities = [PFObject]?()
    let query = PFQuery(className: "Activity")
    var refreshControl = UIRefreshControl()
    
    var segueUser: PFUser?
    var segueImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector (refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        refreshControlAction(refreshControl)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrgActivityCell", forIndexPath: indexPath) as! OrgActivityCell
        
        let activity = activities![indexPath.row]
        //cell.textLabel?.text = activity["type"] as! String
        cell.activity = activity
        cell.delegate = self
        //print(cell.activity)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.activities != nil {
            return self.activities!.count
        }
        return 0
    }
    
    func segueToUserProfile(user: PFUser, image: UIImage) {
        self.segueUser = user
        self.segueImage = image
        self.performSegueWithIdentifier("orgActivityToUserProfileSegue", sender: nil)
    }
    
    func segueToOrgProfile(user: PFUser) {
        self.segueUser = user
        self.performSegueWithIdentifier("orgActivityToOrgProfileSegue", sender: nil)
    }
    
    func fetchActivities(){
        print("fetchActivities")
        query.limit = 20
        query.orderByDescending("CreatedAt")
        query.whereKey("orgID", equalTo: (user?.objectId)!)
        query.findObjectsInBackgroundWithBlock { (activities: [PFObject]?, error: NSError?) -> Void in
            if let activitiesNotNil = activities {
                self.activities = activitiesNotNil
                print(activities)
            } else {
                print(error?.localizedDescription)
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        fetchActivities()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "orgActivityToUserProfileSegue" {
            let destinationVC = segue.destinationViewController as! UserProfileViewController
            destinationVC.user = self.segueUser
            destinationVC.profilePhoto = self.segueImage
        } else if segue.identifier == "orgActivityToOrgProfileSegue" {
            let destinationVC = segue.destinationViewController as! OrgProfileViewController
            destinationVC.user = self.segueUser
        }
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
