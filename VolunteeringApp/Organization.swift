//
//  Organization.swift
//  VolunteeringApp
//
//  Created by Devshi Mehrotra on 7/8/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class Organization: PFUser {
    
    var name: NSString?
    var coverImageURL: NSURL?
    var profileImage: PFFile?
    var currentEvents: [Event] = []
    var completedEvents: [Event] = []
    var followerVol: [Organization] = []

}
