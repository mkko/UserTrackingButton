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
    private var locationTrackingButton: UIButton
    private var locationTrackingImage: UIImageView
    private var locationTrackingWithHeadingImage: UIImageView
    private var trackingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private let serialQueue = dispatch_queue_create("com.mikkovalimaki.UserTrackingButton", DISPATCH_QUEUE_SERIAL);

    internal private(set) var viewState: ViewState = .Initial
    
    private let trackingLocationImageName = "TrackingLocation"
    private let trackingLocationOffImageName = "TrackingLocationOff"
    private let trackingLocationWithHeadingImageName = "TrackingLocationWithHeading"
    private let AnimationDuration = 0.2

    internal enum ViewState {
        case Initial
        case RetrievingLocation
        case TrackingLocationOff
        case TrackingLocation
        case TrackingLocationWithHeading
    }
    
    @IBOutlet public var mapView: MKMapView?
    
    // MARK: Init
    
    required public override init(frame: CGRect) {
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationImageName)
        self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationWithHeadingImageName)
        self.locationOffButton = UserTrackingButton.buttonWithImageNamed(trackingLocationOffImageName, renderingMode: .AlwaysTemplate)
        self.locationTrackingButton = UIButton()
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationImageName)
        self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationWithHeadingImageName)
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
        
        stretchView(locationTrackingWithHeadingImage, withinView: locationTrackingButton)
        stretchView(locationTrackingImage, withinView: locationTrackingButton)
        locationTrackingImage.hidden = true
        locationTrackingWithHeadingImage.hidden = true
        
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
    }
    
    // MARK: Public methods
    
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
    
    // MARK: UI interaction
    
    internal func pressed(sender: UIButton!) {
        guard let mapView = mapView else { return }
        
        let userTrackingMode: MKUserTrackingMode
        switch mapView.userTrackingMode {
        case MKUserTrackingMode.Follow where isMapViewRetrievingLocation(mapView):
            // If still retrieving location, button should abort it.
            userTrackingMode = MKUserTrackingMode.None
        case MKUserTrackingMode.Follow:
            userTrackingMode = MKUserTrackingMode.FollowWithHeading
        case MKUserTrackingMode.FollowWithHeading:
            userTrackingMode = MKUserTrackingMode.None
        default:
            userTrackingMode = MKUserTrackingMode.Follow
        }

        mapView.setUserTrackingMode(userTrackingMode, animated: true)
    }
    
    // MARK: Helper methods
    
    private func transitionToState(state: ViewState, animated: Bool) {
        
        guard self.viewState != state else { return }
        
        let imageShapeWillChange = !(
                [.TrackingLocationOff, .TrackingLocation].contains(self.viewState) &&
                [.TrackingLocationOff, .TrackingLocation].contains(state))
        
        switch state {
        case .RetrievingLocation:
            self.setHidden(locationTrackingButton, locationOffButton, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                self.trackingActivityIndicator.startAnimating()
                self.setHidden(self.trackingActivityIndicator, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
            }
        case .TrackingLocation:
            fallthrough
        case .TrackingLocationWithHeading:
            self.setHidden(self.trackingActivityIndicator, self.locationOffButton, hidden: true, animated: animated, shouldScale: imageShapeWillChange)
            self.setHidden(locationTrackingButton, hidden: false, animated: animated) {
                self.trackingActivityIndicator.stopAnimating()
            }
            if state == .TrackingLocation {
                self.setHidden(self.locationTrackingWithHeadingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                    self.setHidden(self.locationTrackingImage, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
                }
            } else {
                self.setHidden(self.locationTrackingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                    self.setHidden(self.locationTrackingWithHeadingImage, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
                }
            }
        case .TrackingLocationOff:
            self.setHidden(self.trackingActivityIndicator, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                self.trackingActivityIndicator.stopAnimating()
            }
            self.setHidden(self.locationTrackingButton, hidden: true, animated: animated)
            self.setHidden(self.locationTrackingImage, self.locationTrackingWithHeadingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                self.setHidden(self.locationOffButton, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
            }
        default:
            break
        }

        self.viewState = state
    }
    
    private func updateState(forMapView mapView: MKMapView, animated: Bool) {
        
        dispatch_sync(serialQueue) {
            let nextState: ViewState
            switch mapView.userTrackingMode {
            case _ where self.isMapViewRetrievingLocation(mapView):
                nextState = .RetrievingLocation
            case .Follow:
                nextState = .TrackingLocation
            case .FollowWithHeading:
                nextState = .TrackingLocationWithHeading
            default:
                nextState = .TrackingLocationOff
            }
            self.transitionToState(nextState, animated: animated)
        }
    }
    
    private func isMapViewRetrievingLocation(mapView: MKMapView) -> Bool {
        return mapView.userTrackingMode != .None
            && (mapView.userLocation.location == nil
                || mapView.userLocation.location?.horizontalAccuracy >= kCLLocationAccuracyHundredMeters)
    }
    
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
    
    private func setHidden(items: UIView..., hidden: Bool, animated: Bool, shouldScale: Bool = false, completion: (() -> Void)? = nil) {
        
        let itemsToChange = items.filter { $0.hidden != hidden }
        
        for item in itemsToChange {
            item.layer.removeAllAnimations()
            // If the item is hidden make it visible.
            if shouldScale {
                item.transform = item.hidden ? CGAffineTransformMakeScale(0.01, 0.01) : CGAffineTransformIdentity
                item.alpha = 1.0
            } else {
                item.alpha = item.hidden ? 0.0 : 1.0
                item.transform = CGAffineTransformIdentity
            }
            item.hidden = false
        }
        
        let anim: () -> Void = {
            for item in itemsToChange {
                if shouldScale {
                    item.transform = hidden ? CGAffineTransformMakeScale(0.01, 0.01) : CGAffineTransformIdentity
                } else {
                    item.alpha = hidden ? 0.0 : 1.0
                }
            }
        }
        
        let compl: ((Bool) -> Void) = { completed in
            if completed {
                for item in itemsToChange {
                    item.hidden = hidden
                    item.transform = CGAffineTransformIdentity
                }
            }
            completion?()
        }
        
        if animated {
            UIView.animateWithDuration(AnimationDuration, delay: 0, options: .BeginFromCurrentState, animations: anim, completion: compl)
            //UIView.animateWithDuration(0.2, animations: anim, completion: compl)
        } else {
            anim()
            compl(true)
        }
    }
    
    // MARK: Interface Builder
    
    public override func prepareForInterfaceBuilder() {
        self.transitionToState(.TrackingLocationOff, animated: false)
    }
}
