//
//  UserTrackingButton.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 15-12-04.
//  Copyright © 2015 Mikko Välimäki. All rights reserved.
//

import Foundation
import MapKit

let animationDuration = 0.2

@IBDesignable public class UserTrackingButton : UIControl, MKMapViewDelegate {
    
    private var delegateProxy: MapViewDelegateProxy?
    private var locationButton: UIButton = UIButton()
    private var locationOffButton: UIButton = UIButton()
    private var trackingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private var viewState: ViewState = .Initial
    
    enum ViewState {
        case Initial
        case RetrievingLocation
        case TrackingLocationOff
        case TrackingLocation
    }
    
    @IBOutlet public var mapView: MKMapView? {
        didSet {
            if let mapView = mapView {
                self.delegateProxy = MapViewDelegateProxy(mapView: mapView, target: self)
                updateState(forMapView: mapView, animated: false)
            }
        }
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)

        self.addButton(self.locationButton, withImage: getImage("TrackingLocationMask"))
        self.addButton(self.locationOffButton, withImage: getImage("TrackingLocationOffMask"))
        
        self.locationOffButton.hidden = true
        self.locationButton.hidden = true
        self.trackingActivityIndicator.stopAnimating()

        self.trackingActivityIndicator.hidesWhenStopped = true
        self.trackingActivityIndicator.hidden = true
        self.trackingActivityIndicator.userInteractionEnabled = false
        self.trackingActivityIndicator.exclusiveTouch = false
        self.trackingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.trackingActivityIndicator)
        self.addConstraints([
            NSLayoutConstraint(item: self.trackingActivityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.trackingActivityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0),
            ])
        
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    private func addButton(button: UIButton, withImage image: UIImage?) {
        button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        button.setImage(image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        self.addConstraints([
            NSLayoutConstraint(
                item: button,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0),
            ])
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return self.locationButton.intrinsicContentSize()
    }
    
    public override func tintColorDidChange() {
        self.trackingActivityIndicator.tintColor = self.tintColor
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
    
    private func updateState(forMapView mapView: MKMapView, animated: Bool) {
        let state: ViewState
        if mapView.userTrackingMode == .None {
            state = .TrackingLocationOff
        } else if mapView.userLocation.location == nil || mapView.userLocation.location?.horizontalAccuracy >= kCLLocationAccuracyHundredMeters {
            state = .RetrievingLocation
        } else {
            state = .TrackingLocation
        }
        transitionToState(state, animated: animated)
    }
    
    private func transitionToState(state: ViewState, animated: Bool) {

        switch state {
        case .RetrievingLocation:
            self.locationButton.hide(animated) {
                self.locationOffButton.hide(animated) {
                    self.trackingActivityIndicator.hidden = false
                    self.trackingActivityIndicator.startAnimating()
                }
            }
        case .TrackingLocation:
            self.trackingActivityIndicator.stopAnimating()
            
            self.locationOffButton.hide(animated) {
                self.locationButton.show(animated)
            }
        case .TrackingLocationOff:
            self.trackingActivityIndicator.stopAnimating()
            self.locationButton.hide(animated) {
                self.locationOffButton.show(animated)
            }
        default:
            break
        }
        
        self.viewState = state
    }
    
    public func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        updateState(forMapView: mapView, animated: true)
    }
    
    public func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        updateState(forMapView: mapView, animated: true)
    }
    
    public override func prepareForInterfaceBuilder() {
    }
    
    public func getImage(named: String) -> UIImage? {
        return UIImage(named: named, inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
    }
}

extension UIView {
    
    func setHidden(hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        guard self.hidden != hidden else {
            completion?()
            return
        }
        
        if self.hidden {
            self.alpha = 0.0
            self.hidden = false
        }
        
        let anim: () -> Void = {
            self.alpha = hidden ? 0.0 : 1.0
        }
        
        let compl: ((Bool) -> Void) = { _ in
            self.hidden = hidden
            completion?()
        }
        
        if animated {
            UIView.animateWithDuration(0.2, animations: anim, completion: compl)
        } else {
            anim()
            compl(true)
        }
    }
    
    func hide(animated: Bool, completion: (() -> Void)? = nil) {
        setHidden(true, animated: animated, completion: completion)
    }
    
    func show(animated: Bool, completion: (() -> Void)? = nil) {
        setHidden(false, animated: animated, completion: completion)
    }
}
