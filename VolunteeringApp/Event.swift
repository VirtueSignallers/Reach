//
//  modEvent.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/11/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse

class Event: PFObject {
   
    /**
     Method to add a user post to Parse (uploading image file)
     - parameter image: Image that the user wants upload to parse
     - parameter caption: Caption text input by the user
     - parameter completion: Block to be executed after save operation is complete
     */
    class func postEvent(cover_image: UIImage?, hostImage: PFFile?, location: String?, description: String?, startDate: NSDate?, endDate: NSDate?, title: String?, volunteers: [PFUser], tags: [String], withCompletion completion: PFBooleanResultBlock?) {
        
        // create a Parse object PFObject
        let event = PFObject(className: "Event")
        let host = PFUser.currentUser()
        
        event["cover_image"] = getPFFileFromImage(cover_image)
        event["title"] = title
        event["startDate"] = startDate
        event["endDate"] = endDate
        event["duration"] = (Double((endDate?.timeIntervalSinceDate(startDate!))!)/3600)
        event["desc"] = description
        event["host"] = host
        event["host_image"] = hostImage
        event["location"] = location // should probably change to some map view location
        event["attending"] = volunteers
        event["tags"] = tags
        //event["subscribers"] = subscribers
        
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count > 0) {
                let topResult: CLPlacemark = (placemarks?[0])!
                let eventLocation = topResult.location!
                let geoPointLocation = PFGeoPoint(location: eventLocation)
                event["geoLocation"] = geoPointLocation
                event.saveInBackgroundWithBlock(completion)
                
            }
        })
        
        Activity.postActivity("createdEvent", username: host!["name"] as? String, userFBID: "", activity_name: title, imageURL: hostImage?.url, orgID: host!.objectId, withCompletion: nil)
        
        print("COMPLETED")
    }
    
    class func editEvent(event: PFObject, cover_image: UIImage?, hostImage: PFFile?, location: String?, description: String?, startDate: NSDate?, endDate: NSDate?, title: String?, volunteers: [PFUser], tags: [String], withCompletion completion: PFBooleanResultBlock?) {
        
        let host = PFUser.currentUser()
        
        event["cover_image"] = getPFFileFromImage(cover_image)
        event["title"] = title
        event["startDate"] = startDate
        event["endDate"] = endDate
        event["duration"] = (Double((endDate?.timeIntervalSinceDate(startDate!))!)/3600)
        event["desc"] = description
        event["host"] = host
        event["host_image"] = hostImage
        event["location"] = location // should probably change to some map view location
        event["attending"] = volunteers
        event["tags"] = tags
        //event["subscribers"] = subscribers
        
        let geocoder: CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(location!, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count > 0) {
                let topResult: CLPlacemark = (placemarks?[0])!
                let eventLocation = topResult.location!
                let geoPointLocation = PFGeoPoint(location: eventLocation)
                event["geoLocation"] = geoPointLocation
                event.saveInBackgroundWithBlock(completion)
                
            }
        })
        
        Activity.postActivity("editedEvent", username: host!["name"] as? String, userFBID: "", activity_name: title, imageURL: hostImage?.url, orgID: host!.objectId, withCompletion: nil)
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
