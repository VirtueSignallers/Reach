//
//  CreateEventViewController.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/8/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//


/*TO DO:
 make sure end date is after start date 
 make sure no field is empty
 */

import UIKit
import ParseUI
//import GooglePlacesAutocomplete
class CreateEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
    
    var controller: UIAlertController?
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var descriptionLabel: UITextField!

    @IBOutlet weak var coverImageView: PFImageView!
    
    let picker = UIImagePickerController()
    
    var editingEvent: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        if editingEvent == nil {
            titleLabel.placeholder = "Title"
            descriptionLabel.placeholder = "Description"
        } else {
            titleLabel.text = editingEvent!["title"] as? String
            descriptionLabel.text = editingEvent!["desc"] as? String
            coverImageView.file = editingEvent!["cover_image"] as? PFFile
        }
        
        controller = UIAlertController(
            title: "Choose a photo for your event",
            message: "",
            preferredStyle: .ActionSheet)
        let actionEmail = UIAlertAction(title: "Take Photo",
                                        style: UIAlertActionStyle.Default,
                                        handler: {(paramAction:UIAlertAction!) in
                                            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                                                self.picker.allowsEditing = false
                                                self.picker.sourceType = UIImagePickerControllerSourceType.Camera
                                                self.picker.cameraCaptureMode = .Photo
                                                self.presentViewController(self.picker, animated: true, completion: nil)
                                            } else {
                                                self.noCamera()
                                            }
        })
        
        let actionImessage = UIAlertAction(title: "Choose from Library",
                                           style: UIAlertActionStyle.Default,
                                           handler: {(paramAction:UIAlertAction!) in
                                            self.picker.allowsEditing = false
                                            self.picker.sourceType = .PhotoLibrary
                                            self.picker.modalPresentationStyle = .Popover
                                            self.presentViewController(self.picker, animated: true, completion: nil)
        })
        
        let actionDelete = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.Destructive,
                                         handler: {(paramAction:UIAlertAction!) in
        })
        controller!.addAction(actionEmail)
        controller!.addAction(actionImessage)
        controller!.addAction(actionDelete)
        
    }
    
    @IBAction func onPhoto(sender: AnyObject) {
        self.presentViewController(controller!, animated: true, completion: nil)
    }
  
    func textFieldDidBeginEditing(textField: UITextField) {
        titleLabel.placeholder = nil
        descriptionLabel.placeholder = nil
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        //coverImageView.contentMode = .ScaleAspectFit //3
        coverImageView.image = chosenImage //4
        //coverImageView.file = nil
        dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.Default,
            handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC,
                              animated: true,
                              completion: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let destinationVC = segue.destinationViewController as! LocationViewController
        destinationVC.myTitle = self.titleLabel.text!
        
        if coverImageView.image != nil {
            destinationVC.coverImage = coverImageView.image!
        } else {
            destinationVC.coverImage = UIImage(named: "maroon-cover")!
        }
        
        destinationVC.myDesc = self.descriptionLabel.text!
        destinationVC.editingEvent = self.editingEvent
        
        titleLabel.text = ""
        descriptionLabel.text = ""
        coverImageView.image = UIImage(named: "camera")
    }

}
