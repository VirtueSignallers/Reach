//
//  DateViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/18/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class DateViewController: UIViewController, UIImagePickerControllerDelegate {

    var address = ""
    var coverImage: UIImage?
    var myDesc = ""
    var myTitle = ""
    var startDate: NSDate?
    var endDate: NSDate?
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var editingEvent: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDatePicker.setValue(Constant.themeColor, forKey: "textColor")
        endDatePicker.setValue(Constant.themeColor, forKey: "textColor")

        startDatePicker.sendAction("setHighlightsToday:", to: nil, forEvent: nil)
        endDatePicker.sendAction("setHighlightsToday:", to: nil, forEvent: nil)
        
        self.startDate = NSDate()
        self.endDate = NSDate()
        
        if editingEvent == nil {
            startDateLabel.text = ""
            endDateLabel.text = ""
        } else {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            formatter.timeStyle = .ShortStyle
            
            self.startDate = self.editingEvent!["startDate"] as? NSDate
            self.endDate = self.editingEvent!["endDate"] as? NSDate
            
            let startDateString = formatter.stringFromDate(startDate!)
            let endDateString = formatter.stringFromDate(endDate!)
            
            startDateLabel.text = startDateString
            endDateLabel.text = endDateString
            
            startDatePicker.timeZone = NSTimeZone.localTimeZone()
            startDatePicker.setDate(self.startDate!, animated: true)
            endDatePicker.setDate(self.endDate!, animated: true)
        }
        
        startDatePicker.addTarget(self, action: #selector(DateViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        endDatePicker.addTarget(self, action: #selector(DateViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        
        let strDate = dateFormatter.stringFromDate(datePicker.date)
        
        if datePicker == self.startDatePicker {
            startDateLabel.text = strDate
            self.startDate = datePicker.date
        }
        else {
            endDateLabel.text = strDate
            self.endDate = datePicker.date
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
         if self.startDate!.compare(self.endDate!) == .OrderedDescending
        {
            let alert = UIAlertController(title: "Alert", message: "Start date cannot be after end date", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        
        }
         else if self.startDate!.compare(NSDate()) == .OrderedAscending{
            let alert = UIAlertController(title: "Alert", message: "Start date must be in the future", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
         }
         else {
            let destinationVC = segue.destinationViewController as! TagViewController
            
            self.startDateLabel.text = ""
            self.endDateLabel.text = ""
            
            destinationVC.myTitle = self.myTitle
            destinationVC.coverImage = self.coverImage
            destinationVC.myDesc = self.myDesc
            destinationVC.address = self.address
            destinationVC.startDate = self.startDate
            destinationVC.endDate = self.endDate
            destinationVC.address = self.address
            destinationVC.editingEvent = self.editingEvent
           
        }
    }
    

}
