//
//  UserTrackingButtonTest.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 16-07-03.
//  Copyright © 2016 Mikko Välimäki. All rights reserved.
//

import XCTest
import MapKit
@testable import UserTrackingButton

class UserTrackingButtonTest: XCTestCase {
    
    private var button: UserTrackingButton = UserTrackingButton()
    private var mapView: MKMapViewStub = MKMapViewStub()
    private var userLocation = MKUserLocationStub(location: CLLocation(latitude: 0, longitude: 0))
    
    override func setUp() {
        super.setUp()
        button.mapView = mapView
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStateTracking() {
        mapView.setupUserTrackingMode(.follow, location: userLocation)
        
        button.updateStateAnimated(true)
        XCTAssertEqual(.trackingLocation, button.viewState)
    }
    
    func testStateRetrieving() {
        mapView.setupUserTrackingMode(.follow, location: nil)
        
        button.updateStateAnimated(true)
        XCTAssertEqual(.retrievingLocation, button.viewState)
    }
    
    func testStateTrackingWithHeading() {
        mapView.setupUserTrackingMode(.followWithHeading, location: userLocation)
        
        button.updateStateAnimated(true)
        XCTAssertEqual(.trackingLocationWithHeading, button.viewState)
    }
}
