//
//  SearchViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/18/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var bannerView: UIView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredOrgs: [PFObject] = []
    var orgs: [PFObject] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagesListArray = [UIImage(named: "red-cross")!, UIImage(named: "plant-tree")!, UIImage(named: "unicef")!]
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1);
        layout.minimumInteritemSpacing = 0 // this number could be anything <=5. Need it here because the default is 10.
        layout.minimumLineSpacing = 1
        layout.itemSize = CGSizeMake((self.collectionView.frame.size.width-3)/3, (self.collectionView.frame.size.width-3)/3)
        
        self.logoImageView.animationImages = imagesListArray
        self.logoImageView.animationDuration = Double(imagesListArray.count) * 3
        self.logoImageView.startAnimating()
        
        self.tableView.hidden = true 
        
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        self.searchBar.tintColor = UIColor.whiteColor()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        
        let query = PFQuery(className: "_User")
        query.whereKey("userType", equalTo: "Organization")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (orgs: [PFObject]?, error: NSError?) -> Void in
            if let orgsNotNil = orgs {
                self.orgs = orgsNotNil
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print(orgs.count)
        
        if orgs.count < 9 {
            return orgs.count
        } else {
            return 9
        }
        
        //let remainder = orgs.count % 3
        //return orgs.count - remainder
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OrgImageCell", forIndexPath: indexPath) as! OrgImageCell
        
        let org = orgs[indexPath.item]
        print("ORG: \(org)")
        
        cell.user = org as? PFUser
        cell.orgImageView.file = org["orgProfile"] as? PFFile
        cell.orgImageView.loadInBackground()
        
        /*cell.layer.borderWidth = 3
        cell.layer.masksToBounds = false
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.cornerRadius = cell.frame.size.width/8
        cell.clipsToBounds = true*/
        
        //cell.backgroundColor = UIColor.blueColor()
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        collectionView.reloadData()
       return filteredOrgs.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchCell
        
        cell.user = filteredOrgs[indexPath.row]
        
        // cell.textLabel!.text = filteredOrgs[indexPath.row]["name"] as! String
            
        // print("row \(indexPath.row)")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        self.performSegueWithIdentifier("SearchToOrgProfileSegue", sender: filteredOrgs[indexPath.row])
    }
    
    //
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.collectionView.hidden = true
        self.bannerView.hidden = true
        self.tableView.hidden = false
        
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        self.collectionView.hidden = false
        self.bannerView.hidden = false
        self.tableView.hidden = true
    }
    
    func searchBar(searchBar:UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredOrgs = orgs
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            
            filteredOrgs = []
            
            for org in orgs {
                let name = org["name"] as! String
                print(name)
                // If dataItem matches the searchText, return true to include it
                if name.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    //print("\(title)")
                    filteredOrgs.append(org)
                }
            }
            
            /*filteredOrgs = orgs.filter({(dataItem: PFObject) -> Bool in
                let name = dataItem["name"] as! String
                print(name)
                // If dataItem matches the searchText, return true to include it
                if name.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    //print("\(title)")
                    return true
                } else {
                    return false
                }
            })*/
        }
        print("FILTERED: \(filteredOrgs)")
        print("SEARCH BAR")
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(theSearchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "SearchToOrgProfileSegue") {
            //let cell = sender as! SearchCell
            //let indexPath = tableView.indexPathForCell(cell)
            //tableView.deselectRowAtIndexPath(indexPath!, animated:true)
            let org = sender as! PFUser
            let destinationVC = segue.destinationViewController as! OrgProfileViewController
            destinationVC.user = org
        }
        
        else {
            let cell = sender as! OrgImageCell
            let org = cell.user 
            let destinationVC = segue.destinationViewController as! OrgProfileViewController
            destinationVC.user = org
        }
        
    }


}
