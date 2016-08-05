//
//  AchievementViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/20/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class AchievementViewController: UIViewController {

    @IBOutlet weak var achievementLabel: UILabel!
    var achievement: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if achievement != nil {
            achievementLabel.text = achievement
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
