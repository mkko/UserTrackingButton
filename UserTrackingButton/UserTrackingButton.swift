//
//  UserTrackingButton.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 15-12-04.
//  Copyright © 2015 Mikko Välimäki. All rights reserved.
//

import Foundation
import MapKit

@IBDesignable public class UserTrackingButton : UIControl, MKMapViewDelegate {
    
    private var delegateProxy: MapViewDelegateProxy?
    private var button: UIButton
    private var pinpointingIndicator: UIActivityIndicatorView
    
    @IBOutlet public var mapView: MKMapView? {
        didSet {
            if let mapView = mapView {
                self.delegateProxy = MapViewDelegateProxy(mapView: mapView, target: self)
                updateState(forMapView: mapView)
            }
        }
    }
    
    required public override init(frame: CGRect) {
        self.button = UIButton()
        self.pinpointingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        super.init(frame: frame)
        self.setupLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.button = UIButton()
        self.pinpointingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        super.init(coder: aDecoder)
        self.setupLayout()
    }
    
    private func setupLayout() {
        
        self.button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.button)
        self.addConstraints([
            NSLayoutConstraint(
                item: self.button,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: self.button,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: self.button,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: self.button,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0),
            ])
        
        self.pinpointingIndicator.hidesWhenStopped = true
        self.pinpointingIndicator.hidden = true
        self.pinpointingIndicator.userInteractionEnabled = false
        self.pinpointingIndicator.exclusiveTouch = false
        self.pinpointingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.pinpointingIndicator)
        self.addConstraints([
            NSLayoutConstraint(item: self.pinpointingIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.pinpointingIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0),
            ])
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return button.intrinsicContentSize()
    }
    
    func pressed(sender: UIButton!) {
        let userTrackingMode: MKUserTrackingMode
        switch mapView?.userTrackingMode {
        case .Some(MKUserTrackingMode.Follow):
            userTrackingMode = MKUserTrackingMode.None
        default:
            userTrackingMode = MKUserTrackingMode.Follow
        }

        mapView?.setUserTrackingMode(userTrackingMode, animated: true)
    }
    
    private func updateState(forMapView mapView: MKMapView) {
        if mapView.userTrackingMode == .None {
            self.button.setImage(UserTrackingButton.getImage("TrackingLocationOffMask"), forState: .Normal)
            self.pinpointingIndicator.stopAnimating()
        } else if mapView.userLocation.location == nil
            || mapView.userLocation.location?.horizontalAccuracy >= kCLLocationAccuracyHundredMeters {
            self.pinpointingIndicator.hidden = false
            self.pinpointingIndicator.startAnimating()
            self.button.setImage(nil, forState: .Normal)
        } else {
            self.button.setImage(UserTrackingButton.getImage("TrackingLocationMask"), forState: .Normal)
            self.pinpointingIndicator.stopAnimating()
        }
    }
    
    public func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        updateState(forMapView: mapView)
    }
    
    public func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        updateState(forMapView: mapView)
    }
    
    public class func getImage(named: String) -> UIImage? {
        let bundle = NSBundle(forClass: self)
        return UIImage(named: named, inBundle: bundle, compatibleWithTraitCollection: nil)
    }
    
    public override func prepareForInterfaceBuilder() {
        self.button.setImage(UIImage(named: "TrackingLocationMask"), forState: .Normal)
        self.backgroundColor = UIColor.yellowColor()
    }
}
