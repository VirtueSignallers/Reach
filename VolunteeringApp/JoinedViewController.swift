//
//  JoinedViewController.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/12/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import FBSDKShareKit
import Social
import ParseUI
import Parse
import EventKit

class JoinedViewController: UIViewController {
    
    var event: PFObject?
    var imageFile: PFFile?

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarButton.setTitle("ADD TO CALENDAR", forState: UIControlState.Normal)
        calendarButton.setTitleColor(Constant.themeColor, forState: UIControlState.Normal)
        shareButton.layer.borderColor = Constant.themeColor.CGColor
        shareButton.setTitleColor(Constant.themeColor, forState: UIControlState.Normal)
        shareButton.layer.borderWidth = 4.0
        calendarButton.layer.borderColor = Constant.themeColor.CGColor
        calendarButton.setTitleColor(Constant.themeColor, forState: UIControlState.Normal)
        calendarButton.layer.borderWidth = 4.0
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
                        self.calendarButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                        self.calendarButton.layer.borderColor = UIColor.lightGrayColor().CGColor
                        self.calendarButton.enabled = false
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
    
    @IBAction func shareToFacebook(sender: AnyObject) {
        print(PFUser.currentUser())
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            let eventID = event!.objectId!
            facebookSheet.addURL(NSURL(string: "https://pure-thicket-16559.herokuapp.com/event/\(eventID)"))
            facebookSheet.completionHandler = {(result: SLComposeViewControllerResult) -> Void in
                if result == SLComposeViewControllerResult.Done {
                    self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
                } else if result == SLComposeViewControllerResult.Cancelled {
                    
                } else {
                    // dismiss with error
                }
            }
            
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = "I'm volunteering for \(event!["title"]). Join me!"
            
            self.presentViewController(facebookSheet, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func dismissButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
