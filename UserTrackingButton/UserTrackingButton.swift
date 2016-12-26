//
//  UserTrackingButton.swift
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 15-12-04.
//  Copyright © 2015 Mikko Välimäki. All rights reserved.
//

import Foundation
import MapKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


let animationDuration = 0.2

@IBDesignable open class UserTrackingButton : UIControl, MKMapViewDelegate {
    
    fileprivate var delegateProxy: MapViewDelegateProxy?
    fileprivate var locationButton: UIButton = UIButton()
    fileprivate var locationOffButton: UIButton = UIButton()
    fileprivate var trackingActivityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate var viewState: ViewState = .initial
    
    enum ViewState {
        case initial
        case retrievingLocation
        case trackingLocationOff
        case trackingLocation
    }
    
    @IBOutlet open var mapView: MKMapView? {
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
    
    fileprivate func setup() {
        self.addTarget(self, action: #selector(UserTrackingButton.pressed(_:)), for: .touchUpInside)

        self.addButton(self.locationButton, withImage: getImage("TrackingLocationMask"))
        self.addButton(self.locationOffButton, withImage: getImage("TrackingLocationOffMask"))
        
        self.locationOffButton.isHidden = true
        self.locationButton.isHidden = true
        self.trackingActivityIndicator.stopAnimating()

        self.trackingActivityIndicator.hidesWhenStopped = true
        self.trackingActivityIndicator.isHidden = true
        self.trackingActivityIndicator.isUserInteractionEnabled = false
        self.trackingActivityIndicator.isExclusiveTouch = false
        self.trackingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.trackingActivityIndicator)
        self.addConstraints([
            NSLayoutConstraint(item: self.trackingActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.trackingActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            ])
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        self.transitionToState(.trackingLocationOff, animated: false)
    }
    
    open override var intrinsicContentSize : CGSize {
        return self.locationButton.intrinsicContentSize
    }
    
    open override func tintColorDidChange() {
        self.trackingActivityIndicator.tintColor = self.tintColor
    }
    
    internal func pressed(_ sender: UIButton!) {
        let userTrackingMode: MKUserTrackingMode
        switch mapView?.userTrackingMode {
        case .some(MKUserTrackingMode.follow):
            userTrackingMode = MKUserTrackingMode.none
        default:
            userTrackingMode = MKUserTrackingMode.follow
        }

        mapView?.setUserTrackingMode(userTrackingMode, animated: true)
    }
    
    // MARK: MKMapViewDelegate Implementation
    
    open func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        updateState(forMapView: mapView, animated: true)
    }
    
    open func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        updateState(forMapView: mapView, animated: true)
    }
    
    // MARK: Helpers
    
    fileprivate func addButton(_ button: UIButton, withImage image: UIImage?) {
        button.addTarget(self, action: #selector(UserTrackingButton.pressed(_:)), for: .touchUpInside)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        
        self.addConstraints([
            NSLayoutConstraint(
                item: button,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: button,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }
    
    fileprivate func updateState(forMapView mapView: MKMapView, animated: Bool) {
        let state: ViewState
        if mapView.userTrackingMode == .none {
            state = .trackingLocationOff
        } else if mapView.userLocation.location == nil || mapView.userLocation.location?.horizontalAccuracy >= kCLLocationAccuracyHundredMeters {
            state = .retrievingLocation
        } else {
            state = .trackingLocation
        }
        transitionToState(state, animated: animated)
    }
    
    fileprivate func transitionToState(_ state: ViewState, animated: Bool) {
        
        switch state {
        case .retrievingLocation:
            self.hide(locationOffButton, animated: animated)
            self.hide(locationButton, animated: animated) {
                self.trackingActivityIndicator.isHidden = false
                self.trackingActivityIndicator.startAnimating()
            }
        case .trackingLocation:
            self.trackingActivityIndicator.stopAnimating()
            self.hide(locationOffButton, animated: animated)
            self.show(locationButton, animated: animated)
        case .trackingLocationOff:
            self.trackingActivityIndicator.stopAnimating()
            self.hide(locationButton, animated: animated)
            self.show(locationOffButton, animated: animated)
        default:
            break
        }
        
        self.viewState = state
    }
    
    open func getImage(_ named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: type(of: self)), compatibleWith: nil)
    }
    
    // MARK: Interface Builder
    
    open override func prepareForInterfaceBuilder() {
        self.transitionToState(.trackingLocationOff, animated: false)
    }
    
    // MARK: Button visibility
    
    // This would be as extension methods but there was some issues when importing
    // such a framework and using it as extension.
    
//}
//
//extension UIView {
    
    func setHidden(_ button: UIButton, hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        guard button.isHidden != hidden else {
            completion?()
            return
        }
        
        if button.isHidden {
            button.alpha = 0.0
            button.isHidden = false
        }
        
        let anim: () -> Void = {
            button.alpha = hidden ? 0.0 : 1.0
        }
        
        let compl: ((Bool) -> Void) = { _ in
            button.isHidden = hidden
            completion?()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: anim, completion: compl)
        } else {
            anim()
            compl(true)
        }
    }
    
    func hide(_ button: UIButton, animated: Bool, completion: (() -> Void)? = nil) {
        setHidden(button, hidden: true, animated: animated, completion: completion)
    }
    
    func show(_ button: UIButton, animated: Bool, completion: (() -> Void)? = nil) {
        button.superview?.bringSubview(toFront: self)
        setHidden(button, hidden: false, animated: animated, completion: completion)
    }
}
