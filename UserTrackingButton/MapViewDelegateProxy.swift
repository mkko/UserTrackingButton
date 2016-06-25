//
//  RxMKMapViewDelegateProxy.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 16-06-25.
//  Copyright © 2016 Mikko Välimäki. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

extension MKMapView {
    
    public var rx_didChangeUserTrackingMode: Observable<(mode: MKUserTrackingMode, animated: Bool)> {
        return MapViewDelegateProxy.proxyForObject(self)
            .observe(#selector(MKMapViewDelegate.mapView(_:didChangeUserTrackingMode:animated:)))
            .map { params in
                let mapView = params[0] as! MKMapView
                let animated = params[2] as! Bool
                return (mapView.userTrackingMode, animated)
        }
    }
}

class MapViewDelegateProxy: DelegateProxy, MKMapViewDelegate, DelegateProxyType {
    
    static func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let mapView: MKMapView = object as! MKMapView
        return mapView.delegate
    }
    
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let mapView: MKMapView = object as! MKMapView
        mapView.delegate = delegate as? MKMapViewDelegate
    }
}
