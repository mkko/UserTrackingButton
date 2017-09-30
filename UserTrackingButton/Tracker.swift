//
//  Tracker.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 24/09/2017.
//  Copyright © 2017 Mikko Välimäki. All rights reserved.
//

import UIKit
import MapKit

internal enum TrackerState {
    case initial
    case retrievingLocation
    case trackingLocationOff
    case trackingLocation
    case trackingLocationWithHeading
}

public class Tracker: NSObject {

    var state = TrackerState.initial

    let mapView: MKMapView

    var trackedAnnotation: MKAnnotation? {
        didSet {
            if let o = trackedAnnotation as? NSObject {
                o.observe
            }
        }
    }

    private let serialQueue = DispatchQueue(label: "com.mikkovalimaki.UserTrackingButton", attributes: []);

    public init(mapView: MKMapView) {
        self.mapView = mapView
    }

    public func follow(_ annotation: MKAnnotation) {
        self.trackedAnnotation = annotation
    }

    open func updateState(animated: Bool) {

    }

    fileprivate func updateState(forMapView mapView: MKMapView, animated: Bool) {

        serialQueue.sync {
            let nextState: TrackerState
            switch mapView.userTrackingMode {
            case _ where self.isMapViewRetrievingLocation(mapView):
                nextState = .retrievingLocation
            case .follow:
                nextState = .trackingLocation
            case .followWithHeading:
                nextState = .trackingLocationWithHeading
            default:
                nextState = .trackingLocationOff
            }
            //self.transitionToState(nextState, animated: animated)
        }
    }

    fileprivate func isMapViewRetrievingLocation(_ mapView: MKMapView) -> Bool {
        let isAccurate = (mapView.userLocation.location?.horizontalAccuracy)
            .map { $0 < kCLLocationAccuracyHundredMeters }
            ?? false
        return mapView.userTrackingMode != .none
            && (mapView.userLocation.location == nil || !isAccurate)
    }

}
