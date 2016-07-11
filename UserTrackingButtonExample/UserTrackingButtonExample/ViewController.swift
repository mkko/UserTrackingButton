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
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestWhenInUseAuthorization()
        
        toolbar.setItems([
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            MKUserTrackingBarButtonItem(mapView: self.mapView)
            ], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        userTrackingButton.updateStateAnimated(true)
    }
    
    func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        userTrackingButton.updateStateAnimated(true)
    }
}
