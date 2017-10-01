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

extension MKMapView {

    func currentMetersPerPoint() -> Double {
        // The documentation on latitudeDelta states that "one degree
        // of latitude is always approximately 111 kilometers"
        // TODO: Consider also rotation?
        let visibleSpanInMeters = self.region.span.latitudeDelta * 111000
        return visibleSpanInMeters / Double(self.bounds.size.width)
    }
}

public class Tracker: NSObject {

    var state = TrackerState.initial

    let mapView: MKMapView

    let timer: DispatchSourceTimer

    var trackedAnnotation: MKAnnotation? {
        didSet {
            if let o = trackedAnnotation as? NSObject {
                timer.resume()
                o.addObserver(self, forKeyPath: "coordinate", options: .new, context: nil)
            } else {
                timer.suspend()
            }
        }
    }

    private var zoomOnFollow = false

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print("observeValue: \(keyPath)")
        if let a = self.trackedAnnotation {
            //let currentZoomScale: MKZoomScale = Double(mapView.bounds.size.width) / mapView.visibleMapRect.size.width

            //self.mapView.setCenter(a.coordinate, animated: true)
            //print("\(self.mapView.currentMetersPerPoint())")
            //print("\(self.mapView.visibleMapRect.size)")
        }

    }

    private let serialQueue = DispatchQueue(label: "com.mikkovalimaki.UserTrackingButton", attributes: []);

    public init(mapView: MKMapView) {
        self.mapView = mapView

        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(10), leeway: .seconds(1))
        super.init()

        timer.setEventHandler(handler: {
            if let a = self.trackedAnnotation {
                if self.zoomOnFollow {
                    self.zoomOnFollow = false
                    let region = MKCoordinateRegionMakeWithDistance(a.coordinate, 1000, 1000)
                    self.mapView.setRegion(region, animated: false)
                } else {
                    print("\(a.coordinate)")
                    self.mapView.setCenter(a.coordinate, animated: false)
                }
            }
        })
    }

    public func follow(_ annotation: MKAnnotation) {
        self.zoomOnFollow = true
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
