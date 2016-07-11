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
    
    private var locationOffButton: UIButton
    private var locationTrackingImage: UIImageView
    //private var locationTrackingWithHeadingImage: UIImageView
    private var locationTrackingButton: UIButton
    private var trackingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    internal private(set) var viewState: ViewState = .Initial
    
    private let trackingLocationImageName = "TrackingLocation"
    private let trackingLocationOffImageName = "TrackingLocationOff"
    private let trackingLocationWithHeadingImageName = "trackingLocationWithHeading"

    internal enum ViewState {
        case Initial
        case RetrievingLocation
        case TrackingLocationOff
        case TrackingLocation
    }
    
    @IBOutlet public var mapView: MKMapView?
    
    required public override init(frame: CGRect) {
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationImageName)
        //self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationWithHeading)
        self.locationOffButton = UserTrackingButton.buttonWithImageNamed(trackingLocationOffImageName, renderingMode: .AlwaysTemplate)
        self.locationTrackingButton = UIButton()
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationImageName)
        //self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationWithHeading)
        self.locationOffButton = UserTrackingButton.buttonWithImageNamed(trackingLocationOffImageName, renderingMode: .AlwaysTemplate)
        self.locationTrackingButton = UIButton()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        for one in [self, locationTrackingButton, locationOffButton] {
            one.addTarget(self, action: #selector(UserTrackingButton.pressed), forControlEvents: .TouchUpInside)
        }
        
        locationTrackingButton.backgroundColor = self.tintColor
        stretchView(locationTrackingButton, withinView: self)
        sendSubviewToBack(locationTrackingButton)
        
        stretchView(locationTrackingImage, withinView: locationTrackingButton)
        locationTrackingImage.hidden = false
        locationTrackingImage.userInteractionEnabled = false
        
        stretchView(locationOffButton, withinView: self)
        locationOffButton.hidden = true
        
        trackingActivityIndicator.stopAnimating()
        trackingActivityIndicator.hidesWhenStopped = false
        trackingActivityIndicator.hidden = true
        trackingActivityIndicator.userInteractionEnabled = false
        trackingActivityIndicator.exclusiveTouch = false
        trackingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackingActivityIndicator)
        addConstraints([
            NSLayoutConstraint(item: trackingActivityIndicator,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(item: trackingActivityIndicator,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY,
                multiplier: 1,
                constant: 0),
            ])
        
        layer.cornerRadius = 4
        clipsToBounds = true
        
        transitionToState(.TrackingLocationOff, animated: false)
        
        setNeedsLayout()
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return self.locationTrackingImage.intrinsicContentSize()
    }
    
    public override func tintColorDidChange() {
        self.trackingActivityIndicator.tintColor = self.tintColor
        self.locationTrackingButton.backgroundColor = self.tintColor
    }
    
    public func updateStateAnimated(animated: Bool) {
        if let mapView = self.mapView {
            updateState(forMapView: mapView, animated: animated)
        }
    }
    
    internal func pressed(sender: UIButton!) {
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
    
    // MARK: Helpers
    
    private func stretchView(view: UIView, withinView parentView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)
        parentView.addConstraints([
            NSLayoutConstraint(
                item: view,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: parentView,
                attribute: .Leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: view,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: parentView,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: view,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: parentView,
                attribute: .Top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: view,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: parentView,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0),
            ])

    }
    
    private func transitionToState(state: ViewState, animated: Bool) {
        
        guard self.viewState != state else {
            return
        }
        
        switch state {
        case .RetrievingLocation:
            self.hide(locationOffButton, locationTrackingImage, self.locationTrackingButton, animated: animated) {
                self.trackingActivityIndicator.startAnimating()
                self.show(self.trackingActivityIndicator, animated: animated)
            }
        case .TrackingLocation:
            self.hide(self.trackingActivityIndicator, animated: animated)
            self.show(self.locationTrackingImage, self.locationTrackingButton, animated: animated) {
                self.trackingActivityIndicator.stopAnimating()
            }
            self.hide(self.locationOffButton, animated: animated)
        case .TrackingLocationOff:
            self.show(self.locationOffButton, animated: animated)
            self.hide(self.locationTrackingImage, self.locationTrackingButton, self.trackingActivityIndicator, animated: animated) {
                self.trackingActivityIndicator.stopAnimating()
            }
        default:
            break
        }
        
        self.viewState = state
    }
    
    private class func buttonWithImageNamed(imageName: String, renderingMode: UIImageRenderingMode) -> UIButton {
        var button = UIButton()
        button.setImage(UserTrackingButton.imageNamed(imageName, renderingMode: renderingMode), forState: .Normal)
        return button
    }
    
    private class func imageViewWithImageNamed(imageName: String) -> UIImageView {
        return UIImageView(image: self.imageNamed(imageName))
    }

    private class func imageNamed(named: String, renderingMode: UIImageRenderingMode? = nil) -> UIImage? {
        let img = UIImage(named: named, inBundle: NSBundle(forClass: NSClassFromString("UserTrackingButton.UserTrackingButton")!), compatibleWithTraitCollection: nil)
        if let renderingMode = renderingMode {
            return img?.imageWithRenderingMode(renderingMode)
        } else {
            return img
        }
    }

    // MARK: Interface Builder
    
    public override func prepareForInterfaceBuilder() {
        self.transitionToState(.TrackingLocationOff, animated: false)
    }
    
    // MARK: Button visibility
    
    private func hide(items: UIView..., animated: Bool, completion: (() -> Void)? = nil) {
        setHidden(items, hidden: true, animated: animated, completion: completion)
    }
    
    private func show(items: UIView..., animated: Bool, completion: (() -> Void)? = nil) {
        setHidden(items, hidden: false, animated: animated, completion: completion)
    }
    
    private func setHidden(items: [UIView], hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        
        for item in items where item.hidden {
            item.alpha = 0.0
            item.hidden = false
        }
        
        let anim: () -> Void = {
            for item in items {
                item.alpha = hidden ? 0.0 : 1.0
            }
        }
        
        let compl: ((Bool) -> Void) = { _ in
            for item in items {
                item.hidden = hidden
            }
            completion?()
        }
        
        if animated {
            UIView.animateWithDuration(0.2, animations: anim, completion: compl)
        } else {
            anim()
            compl(true)
        }
    }
}
