//
//  TrophyViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/19/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import CNPPopupController

class TrophyViewController: UIViewController, CNPPopupControllerDelegate {
    
   
    @IBOutlet weak var one: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var four: UIButton!
    @IBOutlet weak var five: UIButton!
    @IBOutlet weak var six: UIButton!
    @IBOutlet weak var seven: UIButton!
    @IBOutlet weak var eight: UIButton!
    @IBOutlet weak var nine: UIButton!
    @IBOutlet weak var ten: UIButton!
    @IBOutlet weak var eleven: UIButton!
    @IBOutlet weak var twelve: UIButton!
    
    var existingAchievements: [Int]?
    var achievements: [String]?
    
    var achievementString: String?
    
    let trophyIcons = ["1","2","4","12","15","17","20","21","27","33","34","40"]
    
    var popupController:CNPPopupController = CNPPopupController()

    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonArray : [UIButton] = [one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve]
        
        for index in existingAchievements! {
            buttonArray[index].setImage(UIImage(named: "Valentine_day-"+self.trophyIcons[index]), forState: UIControlState.Normal)
        }
        
        for achievement in achievements! {
            if !Constant.extractBool(achievement) {
                let index = Constant.extractInt(achievement)
                let trophyButton = buttonArray[index]
                UIView.animateWithDuration(0.6 ,
                                                               animations: {
                                                                trophyButton.transform = CGAffineTransformMakeScale(0.6, 0.6)
                    },
                                                               completion: { finish in
                                                                UIView.animateWithDuration(2){
                                                                    trophyButton.transform = CGAffineTransformIdentity
                                                                }
                })
                
                trophyButton.twinkle()
            }
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
    
    func showPopupWithStyle(popupStyle: CNPPopupStyle) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        let title = NSAttributedString(string: "Congratulations!", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(32),NSForegroundColorAttributeName: Constant.themeColor, NSParagraphStyleAttributeName: paragraphStyle])
        let lineOne = NSAttributedString(string: self.achievementString!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(24),NSForegroundColorAttributeName: UIColor.darkGrayColor(),NSParagraphStyleAttributeName: paragraphStyle])
        
        let customView = UIImageView.init(image: UIImage.init(named: "gold-trophy"))
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        let lineOneLabel = UILabel()
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.attributedText = lineOne;
        
        /*let lineTwo = NSAttributedString(string: "With style, using NSAttributedString", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(18), NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0), NSParagraphStyleAttributeName: paragraphStyle])
        
        let button = CNPPopupButton.init(frame: CGRectMake(0, 0, 200, 60))
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        button.setTitle("Close Me", forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.init(colorLiteralRed: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController.dismissPopupControllerAnimated(true)
            print("Block for button: \(button.titleLabel?.text)")
        }
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        let lineOneLabel = UILabel()
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.attributedText = lineOne;
        
        let imageView = UIImageView.init(image: UIImage.init(named: "icon"))
        
        let lineTwoLabel = UILabel()
        lineTwoLabel.numberOfLines = 0;
        lineTwoLabel.attributedText = lineTwo;
        
        let customView = UIView.init(frame: CGRectMake(0, 0, 250, 55))
        customView.backgroundColor = UIColor.lightGrayColor()
        
        let textField = UITextField.init(frame: CGRectMake(10, 10, 230, 35))
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = "Custom view!"
        customView.addSubview(textField)*/
        
        self.popupController = CNPPopupController(contents:[titleLabel, lineOneLabel, customView])
        self.popupController.theme = CNPPopupTheme.defaultTheme()
        self.popupController.theme.popupStyle = popupStyle
        self.popupController.delegate = self
        self.popupController.presentPopupControllerAnimated(true)
    }
    
    @IBAction func trophyButtonClicked(sender: UIButton) {
        if sender.currentImage != UIImage(named: "question-mark-clear") {
            
            let buttonArray : [UIButton] = [one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve]
            
            let index = buttonArray.indexOf(sender as! UIButton)
            
            self.achievementString = Constant.achievements[index!]
            
            for achievement in self.achievements! {
                if Constant.extractInt(achievement) == index {
                    let currentIndex = self.achievements!.indexOf(achievement)
                    self.achievements![currentIndex!] = "\(index!) t"
                }
            }
            
            let user = PFUser.currentUser()
            user!.setObject(self.achievements!, forKey: "achievements")
            user?.saveInBackground()
            
            self.showPopupWithStyle(CNPPopupStyle.Centered)
            
            //performSegueWithIdentifier("trophyToAchievementSegue", sender: sender)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! AchievementViewController
        
        let buttonArray : [UIButton] = [one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve]
        
        let index = buttonArray.indexOf(sender as! UIButton)
        
        destinationVC.achievement = Constant.achievements[index!] + "!"
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}

extension ViewController : CNPPopupControllerDelegate {
    
    func popupController(controller: CNPPopupController, dismissWithButtonTitle title: NSString) {
        print("Dismissed with button title \(title)")
    }
    
    func popupControllerDidPresent(controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
}


