//
//  Volunteer.swift
//  VolunteeringApp
//
//  Created by Juan Luis Herrero Estrada on 7/7/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit

class Volunteer: PFUser {
    
    var name: NSString?
    var coverImageURL: NSURL?
    var profileImageURL: NSURL?
    var currentEvents: [Event] = []
    var completedEvents: [Event] = []
    var followingOrgs: [Organization] = []

}
