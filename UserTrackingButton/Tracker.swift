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

    let locationManager: CLLocationManager

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

    public init(mapView: MKMapView) {
        self.mapView = mapView
        self.locationManager = CLLocationManager()
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue.main)
        timer.schedule(deadline: .now() + DispatchTimeInterval.seconds(3), repeating: .milliseconds(10), leeway: .milliseconds(100))
        super.init()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        timer.setEventHandler(handler: {
//            if let a = self.trackedAnnotation {
//                if self.zoomOnFollow {
//                    self.zoomOnFollow = false
//                    let region = MKCoordinateRegionMakeWithDistance(a.coordinate, 1000, 1000)
//                    self.mapView.setRegion(region, animated: false)
//                } else {
//                    print("\(a.coordinate)")
//                    self.mapView.setCenter(a.coordinate, animated: false)
//                }
//            }
        })
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print("observeValue: \(keyPath)")
        if let a = self.trackedAnnotation {
            //let currentZoomScale: MKZoomScale = Double(mapView.bounds.size.width) / mapView.visibleMapRect.size.width

//            let region = MKCoordinateRegionMakeWithDistance(a.coordinate, 1000, 1000)
//            self.mapView.setRegion(region, animated: false)

            //self.mapView.setCenter(a.coordinate, animated: true)
            //print("\(self.mapView.currentMetersPerPoint())")
            //print("\(self.mapView.visibleMapRect.size)")
        }

    }

    private let serialQueue = DispatchQueue(label: "com.mikkovalimaki.UserTrackingButton", attributes: []);

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

extension Tracker: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            if self.zoomOnFollow {
                self.zoomOnFollow = false
                let region = MKCoordinateRegionMakeWithDistance(loc.coordinate, 1000, 1000)
                self.mapView.setRegion(region, animated: false)
            } else {
                print("\(loc.coordinate)")
                self.mapView.setCenter(loc.coordinate, animated: false)
            }
        }
    }
}
