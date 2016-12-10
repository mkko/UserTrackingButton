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
    private var trackingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let serialQueue = DispatchQueue(label: "com.mikkovalimaki.UserTrackingButton")

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
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(imageName: trackingLocationImageName)
        self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(imageName: trackingLocationWithHeadingImageName)
        self.locationOffButton = UserTrackingButton.buttonWithImageNamed(imageName: trackingLocationOffImageName, renderingMode: .alwaysTemplate)
        self.locationTrackingButton = UIButton()
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.locationTrackingImage = UserTrackingButton.imageViewWithImageNamed(imageName: trackingLocationImageName)
        self.locationTrackingWithHeadingImage = UserTrackingButton.imageViewWithImageNamed(imageName: trackingLocationWithHeadingImageName)
        self.locationOffButton = UserTrackingButton.buttonWithImageNamed(imageName: trackingLocationOffImageName, renderingMode: .alwaysTemplate)
        self.locationTrackingButton = UIButton()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        for one in [self, locationTrackingButton, locationOffButton] as [Any] {
            (one as AnyObject).addTarget(self, action: #selector(UserTrackingButton.pressed), for: .touchUpInside)
        }
        
        locationTrackingButton.backgroundColor = self.tintColor
        stretchView(view: locationTrackingButton, withinView: self)
        sendSubview(toBack: locationTrackingButton)
        
        stretchView(view: locationTrackingWithHeadingImage, withinView: locationTrackingButton)
        stretchView(view: locationTrackingImage, withinView: locationTrackingButton)
        locationTrackingImage.isHidden = true
        locationTrackingWithHeadingImage.isHidden = true
        
        stretchView(view: locationOffButton, withinView: self)
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
        
        transitionToState(state: .TrackingLocationOff, animated: false)
    }
    
    // MARK: Public methods
    
    override public var intrinsicContentSize: CGSize {
        return self.locationTrackingImage.intrinsicContentSize
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
        case MKUserTrackingMode.follow where isMapViewRetrievingLocation(mapView: mapView):
            // If still retrieving location, button should abort it.
            userTrackingMode = MKUserTrackingMode.none
        case MKUserTrackingMode.follow:
            userTrackingMode = MKUserTrackingMode.followWithHeading
        case MKUserTrackingMode.followWithHeading:
            userTrackingMode = MKUserTrackingMode.none
        default:
            userTrackingMode = MKUserTrackingMode.follow
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
            self.setHidden(items: locationTrackingButton, locationOffButton, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                self.trackingActivityIndicator.startAnimating()
                self.setHidden(items: self.trackingActivityIndicator, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
            }
        case .TrackingLocation:
            fallthrough
        case .TrackingLocationWithHeading:
            self.setHidden(items: self.trackingActivityIndicator, self.locationOffButton, hidden: true, animated: animated, shouldScale: imageShapeWillChange)
            self.setHidden(items: locationTrackingButton, hidden: false, animated: animated) {
                self.trackingActivityIndicator.stopAnimating()
            }
            if state == .TrackingLocation {
                self.setHidden(items: self.locationTrackingWithHeadingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                    self.setHidden(items: self.locationTrackingImage, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
                }
            } else {
                self.setHidden(items: self.locationTrackingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                    self.setHidden(items: self.locationTrackingWithHeadingImage, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
                }
            }
        case .TrackingLocationOff:
            self.setHidden(items: self.trackingActivityIndicator, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                self.trackingActivityIndicator.stopAnimating()
            }
            self.setHidden(items: self.locationTrackingButton, hidden: true, animated: animated)
            self.setHidden(items: self.locationTrackingImage, self.locationTrackingWithHeadingImage, hidden: true, animated: animated, shouldScale: imageShapeWillChange) {
                self.setHidden(items: self.locationOffButton, hidden: false, animated: animated, shouldScale: imageShapeWillChange)
            }
        default:
            break
        }

        self.viewState = state
    }
    
    private func updateState(forMapView mapView: MKMapView, animated: Bool) {
        
        serialQueue.sync() {
            let nextState: ViewState
            switch mapView.userTrackingMode {
            case _ where self.isMapViewRetrievingLocation(mapView: mapView):
                nextState = .RetrievingLocation
            case .follow:
                nextState = .TrackingLocation
            case .followWithHeading:
                nextState = .TrackingLocationWithHeading
            default:
                nextState = .TrackingLocationOff
            }
            self.transitionToState(state: nextState, animated: animated)
        }
    }
    
    private func isMapViewRetrievingLocation(mapView: MKMapView) -> Bool {
        return mapView.userTrackingMode != .none
            && (mapView.userLocation.location == nil
                || (mapView.userLocation.location?.horizontalAccuracy)! >= kCLLocationAccuracyHundredMeters)
    }
    
    private func stretchView(view: UIView, withinView parentView: UIView) {
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
    
    private class func buttonWithImageNamed(imageName: String, renderingMode: UIImageRenderingMode) -> UIButton {
        let button = UIButton()
        button.setImage(UserTrackingButton.imageNamed(named: imageName, renderingMode: renderingMode), for: .normal)
        return button
    }
    
    private class func imageViewWithImageNamed(imageName: String) -> UIImageView {
        return UIImageView(image: self.imageNamed(named: imageName))
    }
    
    private class func imageNamed(named: String, renderingMode: UIImageRenderingMode? = nil) -> UIImage? {
        let img = UIImage(named: named, in: Bundle(for: NSClassFromString("UserTrackingButton.UserTrackingButton")!), compatibleWith: nil)
        if let renderingMode = renderingMode {
            return img?.withRenderingMode(renderingMode)
        } else {
            return img
        }
    }
    
    private func setHidden(items: UIView..., hidden: Bool, animated: Bool, shouldScale: Bool = false, completion: (() -> Void)? = nil) {
        
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
    
    public override func prepareForInterfaceBuilder() {
        self.transitionToState(state: .TrackingLocationOff, animated: false)
    }
}
