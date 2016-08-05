//
//  Event.swift
//  VolunteeringApp
//
//  Created by Juan Luis Herrero Estrada on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse
class Event1: NSObject {
    
    var cover_image: PFFile?
    var title: String?
    var date: String?
    var desc: String?
    var host: PFUser?
    var host_image: PFFile?
    var location: CLLocation?
    var attending: [Volunteer] = [] 
    
    /**
     Method to add a user post to Parse (uploading image file)
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
    class func postEvent(Coverimage: UIImage?, hostImage: PFFile?, location: String?, description: String?, date: String?, title: String?, volunteers: [Volunteer], withCompletion completion: PFBooleanResultBlock?) {
        // create a Parse object PFObject
        let event = PFObject(className: "Event")
        
        event["cover_image"] = getPFFileFromImage(Coverimage)
        event["title"] = title
        event["date"] = date
        event["desc"] = description
        event["host"] = PFUser.currentUser()
        event["host_image"] = hostImage 
        //event["location"] = location // should probably change to some map view location
        event["attending"] = volunteers
        
        let address: String = location!
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(address,completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count > 0) {
                let topResult: CLPlacemark = (placemarks?[0])!
                let coordLocation: CLLocation = topResult.location!
                event["location"] = coordLocation
            }
        })
        
        // save object (following will save the object in Parse asynchronously)
        event.saveInBackgroundWithBlock(completion)
    }
    
    
    /**
     Method to convert UIImage to PFFile
     - parameter image: Image that the user wants to upload to parse
     - returns: PFFile for the the data in the image
     */
    class func getPFFileFromImage(image: UIImage?) -> PFFile? {
        if let image = image {
            if let imageData = UIImagePNGRepresentation(image){
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }

}
