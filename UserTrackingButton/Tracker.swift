//
//  Tracker.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 24/09/2017.
//  Copyright © 2017 Mikko Välimäki. All rights reserved.
//

import UIKit

internal enum TrackerState {
    case initial
    case retrievingLocation
    case trackingLocationOff
    case trackingLocation
    case trackingLocationWithHeading
}

class Tracker: NSObject {

    var state = TrackerState.initial

}
