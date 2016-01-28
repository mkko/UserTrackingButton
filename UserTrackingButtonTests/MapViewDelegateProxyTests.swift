//
//  MapViewDelegateProxyTests.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 16-01-27.
//  Copyright © 2016 Mikko Välimäki. All rights reserved.
//

import XCTest
import UserTrackingButton
import MapKit

class MapViewDelegateProxyTests: XCTestCase {
    
    var map: MKMapView! = nil
    
    var proxy: MapViewDelegateProxy! = nil
    
    var originaleDelegate: TestDelegate! = nil

    var trackingButton: TestDelegate! = nil

    override func setUp() {
        super.setUp()
        
        map = MKMapView()
        originaleDelegate = TestDelegate()
        trackingButton = TestDelegate()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testProxySetAfterDelegate() {
        
        self.map.delegate = originaleDelegate
        self.proxy = MapViewDelegateProxy(mapView: self.map, target: trackingButton)
        
        XCTAssertTrue(self.map.delegate === self.proxy)
        
        testOriginalDelegate()
    }
    
    func testProxySetBeforeDelegate() {
        
        self.proxy = MapViewDelegateProxy(mapView: self.map, target: trackingButton)
        // Proxy sets itself as a delegate on init.
        XCTAssertTrue(self.map.delegate === self.proxy)
        
        self.map.delegate = originaleDelegate
        // Proxy steals the delegate status.
        XCTAssertTrue(self.map.delegate === self.proxy)
        
        testOriginalDelegate()
    }
    
    func testWorksWithAnotherProxies() {
        
        self.proxy = MapViewDelegateProxy(mapView: self.map, target: trackingButton)

        weak var expectation = expectationWithDescription("Does not hang")
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {

            let anotherTrackingButton = TestDelegate()
            let anotherProxy = MapViewDelegateProxy(mapView: self.map, target: anotherTrackingButton)
            
            XCTAssertTrue([self.proxy, anotherProxy].contains { $0 === self.map.delegate })
            
            expectation?.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(1000.0) { error in
            XCTAssertNil(error, error?.localizedDescription ?? "")
        }
    }
    
    private func testOriginalDelegate() {
        // Verify that the reference to the original delegate was set correctly.
        guard let od = self.proxy.orignalDelegate else {
            XCTAssert(false, "No reference to the original delegate")
            return
        }
        
        XCTAssertTrue(od === originaleDelegate)
    }

}

class TestDelegate: NSObject, MKMapViewDelegate {

}