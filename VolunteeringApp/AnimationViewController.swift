//
//  AnimationViewController.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/25/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Twinkle
class AnimationViewController: UIViewController {

    //@IBOutlet weak var animatedView: UIImageView!
    @IBOutlet weak var heartBall: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.heartBall.center.x = self.view.center.x - 100
    }
    
    override func viewDidAppear(animated: Bool) {
       
        let initialX = self.heartBall.center.x
        let initialY = self.heartBall.center.y
        
        let bezierPath = UIBezierPath()
        
        bezierPath.moveToPoint(CGPointMake(initialX, initialY))
        bezierPath.addCurveToPoint(CGPointMake(initialX + 100, initialY - 120), controlPoint1: CGPointMake(initialX, initialY), controlPoint2: CGPointMake(initialX + 50, initialY - 120))
        bezierPath.addCurveToPoint(CGPointMake(initialX + 200, initialY), controlPoint1: CGPointMake(initialX + 150, initialY - 120), controlPoint2: CGPointMake(initialX + 200, initialY))
        UIColor.redColor().setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.repeatCount = 0 // How many times to repeat the animation
        animation.duration = 1.5 // Duration of a single repetition
        animation.path = bezierPath.CGPath
        heartBall.layer.addAnimation(animation, forKey: "move image along bezier path")
        heartBall.twinkle()
        
        self.heartBall.center.x = initialX + 200
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

} // end of animation class
