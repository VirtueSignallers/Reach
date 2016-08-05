//
//  Activity.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/13/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Parse

class Activity: PFObject {
    
    // activity types: followedOrg, joinedEvent
    // depending on the type of activity, either event or organization will be nil
    class func postActivity(type: String?, username: String?, userFBID: String?, activity_name: String?, imageURL: String?, orgID: String?, withCompletion completion: PFBooleanResultBlock?) {
        let activity = PFObject(className: "Activity")
        activity["type"] = type
        activity["user"] = username
        activity["user_image"] = imageURL
        activity["userFBID"] = userFBID
        activity["activity_name"] = activity_name
        activity["orgID"] = orgID
        activity.saveInBackgroundWithBlock(completion)
    }
}
