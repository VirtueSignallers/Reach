//
//  SelectionViewController.swift
//  VolunteeringApp
//
//  Created by Juan Luis Herrero Estrada on 7/26/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
   
    @IBOutlet weak var orgButton: UIButton!
    @IBOutlet weak var volButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.orgButton.layer.cornerRadius = orgButton.frame.size.width / 30
        self.orgButton.clipsToBounds = true
        self.orgButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        //self.orgButton.layer.borderWidth = 2.0
        //self.orgButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.volButton.layer.cornerRadius = volButton.frame.size.width / 30
        self.volButton.clipsToBounds = true
        //self.volButton.layer.borderWidth = 2.0
        self.volButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        //self.volButton.layer.borderColor = Constant.themeColor.CGColor
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onVolunteerButton(sender: AnyObject) {
        volButton.layer.borderWidth = 2
        volButton.layer.borderColor = UIColor.whiteColor().CGColor
        volButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
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
