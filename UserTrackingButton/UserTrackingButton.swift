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

@IBDesignable open class UserTrackingButton : UIControl, MKMapViewDelegate {
    
    fileprivate var locationOffButton: UIButton
    fileprivate var locationTrackingButton: UIButton
    fileprivate var locationTrackingImage: UIImageView
    fileprivate var locationTrackingWithHeadingImage: UIImageView
    fileprivate var trackingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate let serialQueue = DispatchQueue(label: "com.mikkovalimaki.UserTrackingButton", attributes: []);

    internal fileprivate(set) var viewState: ViewState = .initial
    
    fileprivate let trackingLocationImageName = "TrackingLocation"
    fileprivate let trackingLocationOffImageName = "TrackingLocationOff"
    fileprivate let trackingLocationWithHeadingImageName = "TrackingLocationWithHeading"
    fileprivate let AnimationDuration = 0.2

    internal enum ViewState {
        case initial
        case retrievingLocation
        case trackingLocationOff
        case trackingLocation
        case trackingLocationWithHeading
    }
    
    @IBOutlet open var mapView: MKMapView?
    
    // MARK: Init
    
    required public override init(frame: CGRect) {
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationImageName)
        self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationWithHeadingImageName)
        self.locationOffButton = UserTrackingButton.buttonWithImageNamed(trackingLocationOffImageName, renderingMode: .alwaysTemplate)
        self.locationTrackingButton = UIButton()
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationImageName)
        self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(trackingLocationWithHeadingImageName)
        self.locationOffButton = UserTrackingButton.buttonWithImageNamed(trackingLocationOffImageName, renderingMode: .alwaysTemplate)
        self.locationTrackingButton = UIButton()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        for one in [self, locationTrackingButton, locationOffButton] as [Any] {
            (one as AnyObject).addTarget(self, action: #selector(UserTrackingButton.pressed(_:)), for: .touchUpInside)
        }
        
        locationTrackingButton.backgroundColor = self.tintColor
        stretchView(locationTrackingButton, withinView: self)
        sendSubview(toBack: locationTrackingButton)
        
        stretchView(locationTrackingWithHeadingImage, withinView: locationTrackingButton)
        stretchView(locationTrackingImage, withinView: locationTrackingButton)
        locationTrackingImage.isHidden = true
        locationTrackingWithHeadingImage.isHidden = true
        
        stretchView(locationOffButton, withinView: self)
        locationOffButton.isHidden = true
        
        trackingActivityIndicator.stopAnimating()
        trackingActivityIndicator.hidesWhenStopped = false
        trackingActivityIndicator.isHidden = true
        trackingActivityIndicator.isUserInteractionEnabled = false
        trackingActivityIndicator.isExclusiveTouch = false
        trackingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackingActivityIndicator)
        addConstraints([
            NSLayoutConstraint(item: trackingActivityIndicator,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(item: trackingActivityIndicator,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1,
                constant: 0),
            ])
        
        layer.cornerRadius = 4
        clipsToBounds = true
        
        transitionToState(.trackingLocationOff, animated: false)
    }
    
    // MARK: Public methods
    
    open override var intrinsicContentSize : CGSize {
        return self.locationTrackingImage.intrinsicContentSize
    }
    
    open override func tintColorDidChange() {
        self.trackingActivityIndicator.tintColor = self.tintColor
        self.locationTrackingButton.backgroundColor = self.tintColor
    }
    
    open func updateStateAnimated(_ animated: Bool) {
        if let mapView = self.mapView {
            updateState(forMapView: mapView, animated: animated)
        }
    }
    
    // MARK: UI interaction
    
    @objc internal func pressed(_ sender: UIButton!) {
        guard let mapView = mapView else { return }
        
        let userTrackingMode: MKUserTrackingMode
        switch mapView.userTrackingMode {
        case MKUserTrackingMode.follow where isMapViewRetrievingLocation(mapView):
            // If still retrieving location, button should abort it.
            userTrackingMode = .none
        case MKUserTrackingMode.follow:
            userTrackingMode = .followWithHeading
        case MKUserTrackingMode.followWithHeading:
            userTrackingMode = .none
        default:
            userTrackingMode = .follow
        }

        mapView.setUserTrackingMode(userTrackingMode, animated: true)
    }
    
    // MARK: Helper methods
    
    fileprivate func transitionToState(_ state: ViewState, animated: Bool) {
        
        guard self.viewState != state else { return }
        
        let imageShapeWillChange = !(
                [.trackingLocationOff, .trackingLocation].contains(self.viewState) &&
                [.trackingLocationOff, .trackingLocation].contains(state))
        
        switch state {
        case .retrievingLocation:
            self.setHidden(locationTrackingButton, locationOffButton, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                self.trackingActivityIndicator.startAnimating()
                self.setHidden(self.trackingActivityIndicator, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
            }
        case .trackingLocation:
            fallthrough
        case .trackingLocationWithHeading:
            self.setHidden(self.trackingActivityIndicator, self.locationOffButton, hidden: true, animated: animated, shouldScale: imageShapeWillChange)
            self.setHidden(locationTrackingButton, hidden: false, animated: animated) {
                self.trackingActivityIndicator.stopAnimating()
            }
            if state == .trackingLocation {
                self.setHidden(self.locationTrackingWithHeadingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                    self.setHidden(self.locationTrackingImage, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
                }
            } else {
                self.setHidden(self.locationTrackingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                    self.setHidden(self.locationTrackingWithHeadingImage, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
                }
            }
        case .trackingLocationOff:
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
    
    fileprivate func updateState(forMapView mapView: MKMapView, animated: Bool) {
        
        serialQueue.sync {
            let nextState: ViewState
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
            self.transitionToState(nextState, animated: animated)
        }
    }
    
    fileprivate func isMapViewRetrievingLocation(_ mapView: MKMapView) -> Bool {
        let isAccurate = (mapView.userLocation.location?.horizontalAccuracy)
            .map { $0 < kCLLocationAccuracyHundredMeters }
            ?? false
        return mapView.userTrackingMode != .none
            && (mapView.userLocation.location == nil || !isAccurate)
    }
    
    fileprivate func stretchView(_ view: UIView, withinView parentView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)
        parentView.addConstraints([
            NSLayoutConstraint(
                item: view,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: view,
                attribute: .top,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: view,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
        
    }
    
    fileprivate class func buttonWithImageNamed(_ imageName: String, renderingMode: UIImageRenderingMode) -> UIButton {
        let button = UIButton()
        button.setImage(UserTrackingButton.imageNamed(imageName, renderingMode: renderingMode), for: UIControlState())
        return button
    }
    
    fileprivate class func imageViewWithImageNamed(_ imageName: String) -> UIImageView {
        return UIImageView(image: self.imageNamed(imageName))
    }
    
    fileprivate class func imageNamed(_ named: String, renderingMode: UIImageRenderingMode? = nil) -> UIImage? {
        let img = UIImage(named: named, in: Bundle(for: NSClassFromString("UserTrackingButton.UserTrackingButton")!), compatibleWith: nil)
        if let renderingMode = renderingMode {
            return img?.withRenderingMode(renderingMode)
        } else {
            return img
        }
    }
    
    fileprivate func setHidden(_ items: UIView..., hidden: Bool, animated: Bool, shouldScale: Bool = false, completion: (() -> Void)? = nil) {
        
        let itemsToChange = items.filter { $0.isHidden != hidden }
        
        for item in itemsToChange {
            item.layer.removeAllAnimations()
            // If the item is hidden make it visible.
            if shouldScale {
                item.transform = item.isHidden ? CGAffineTransform(scaleX: 0.01, y: 0.01) : CGAffineTransform.identity
                item.alpha = 1.0
            } else {
                item.alpha = item.isHidden ? 0.0 : 1.0
                item.transform = CGAffineTransform.identity
            }
            item.isHidden = false
        }
        
        let anim: () -> Void = {
            for item in itemsToChange {
                if shouldScale {
                    item.transform = hidden ? CGAffineTransform(scaleX: 0.01, y: 0.01) : CGAffineTransform.identity
                } else {
                    item.alpha = hidden ? 0.0 : 1.0
                }
            }
        }
        
        let compl: ((Bool) -> Void) = { completed in
            if completed {
                for item in itemsToChange {
                    item.isHidden = hidden
                    item.transform = CGAffineTransform.identity
                }
            }
            completion?()
        }
        
        if animated {
            UIView.animate(withDuration: AnimationDuration, delay: 0, options: .beginFromCurrentState, animations: anim, completion: compl)
            //UIView.animateWithDuration(0.2, animations: anim, completion: compl)
        } else {
            anim()
            compl(true)
        }
    }
    
    // MARK: Interface Builder
    
    open override func prepareForInterfaceBuilder() {
        self.transitionToState(.trackingLocationOff, animated: false)
    }
}
