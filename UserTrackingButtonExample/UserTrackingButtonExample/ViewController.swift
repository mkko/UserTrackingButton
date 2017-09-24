//
//  ViewController.swift
//  UserTrackingButtonExample
//
//  Created by Mikko Välimäki on 15-12-07.
//  Copyright © 2015 Mikko Välimäki. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserTrackingButton

class ViewController: UIViewController {

    @IBOutlet var userTrackingButton: UserTrackingButton!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            self.mapView.camera = MapCamera()
        }
    }
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestWhenInUseAuthorization()
        
        toolbar.setItems([
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            MKUserTrackingBarButtonItem(mapView: self.mapView)
            ], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        userTrackingButton.updateStateAnimated(true)
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        userTrackingButton.updateStateAnimated(true)
    }
}

class MapCamera: MKMapCamera {

    override var centerCoordinate: CLLocationCoordinate2D {
        set {
            super.centerCoordinate = newValue
        }
        get {
            return super.centerCoordinate
        }
//        willSet {
//            print("willSet centerCoordinate: \(centerCoordinate)")
//        }
//        didSet {
//            print("didSet centerCoordinate: \(centerCoordinate)")
////            let c = CLLocationCoordinate2D(
////                latitude: centerCoordinate.latitude + 1,
////                longitude: centerCoordinate.longitude
////            )
////            super.centerCoordinate = c
//        }
    }

    override var pitch: CGFloat {
        didSet {
            print("didSet pitch: \(pitch)")
        }
    }

    override init() {
        super.init()
        self.observeValue(forKeyPath: "centerCoordinate", of: self, change: nil, context: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("observeValue: \(String(describing: keyPath))")
    }

    override func setValue(_ value: Any?, forKey key: String) {
        print("setValue, key: \(key)")
        super.setValue(value, forKey: key)
    }

    override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        print("setValue, keyPath: \(keyPath)")
        super.setValue(value, forKeyPath: keyPath)
    }

}

