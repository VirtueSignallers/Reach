//
//  FriendsViewController.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4
import AFNetworking

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let user = PFUser.currentUser()
    var activities: [PFObject] = []
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    var segueUser: PFUser?
    var segueImage: UIImage?
    
    override func viewDidLoad() {
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendsActivityCell
        let activity = activities[indexPath.row]
        cell.delegate = self
        cell.activity = activity
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.activities.count
    }
    
    func segueToUserProfile(user: PFUser, image: UIImage) {
        self.segueUser = user
        self.segueImage = image
        self.performSegueWithIdentifier("friendsToUserProfileSegue", sender: nil)
    }
    
    func segueToOrgProfile(user: PFUser) {
        self.segueUser = user
        self.performSegueWithIdentifier("friendsToOrgProfileSegue", sender: nil)
    }
    
    func fetchActivities(){
        let query = PFQuery(className: "Activity")
        query.limit = 20
        query.orderByDescending("_created_at")
        query.findObjectsInBackgroundWithBlock { (activities: [PFObject]?, error: NSError?) -> Void in
            
            if let activitiesNotNil = activities {
                self.activities = []
                for activity in activitiesNotNil{
                    let userID = activity["userFBID"] as? String
                    let orgID = activity["orgID"] as? String
                    
                    let friendsIDArray = PFUser.currentUser()!["friend_id_array"] as? [String]
                    
                    var subscribedOrgIDs = [String]()
                    print(self.user)
                    let subscribedOrgs = PFUser.currentUser()!["subscribed"] as? [PFUser]
                    print(subscribedOrgs)
                    for org in subscribedOrgs! {
                        subscribedOrgIDs.append(org.objectId!)
                    }
                
                    if friendsIDArray!.contains(userID!) || (subscribedOrgIDs.contains(orgID!) && userID! == ""){ // retrieve only the activities done by your friends on facebook
                        self.activities.append(activity)
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
        fetchActivities()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "friendsToUserProfileSegue" {
            let destinationVC = segue.destinationViewController as! UserProfileViewController
            destinationVC.user = self.segueUser
            destinationVC.profilePhoto = self.segueImage
        } else if segue.identifier == "friendsToOrgProfileSegue" {
            let destinationVC = segue.destinationViewController as! OrgProfileViewController
            destinationVC.user = self.segueUser
        }
    }

} // end of class
