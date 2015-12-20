# UserTrackingButton

A replacement for `MKUserTrackingBarButtonItem` when you don't have toolbars or navigation bars.

 `UserTrackingButton` is a button that works in conjunction with `MKMapView`. Unlike `MKUserTrackingBarButtonItem` it can be used even when you don't have toolbars or navigation bars.
 
## Installation

#### Carthage

Add `github "mkko/UserTrackingButton" ~> 0.1` to you `Cartfile`. Follow the further instrcutions on [Carthage getting started][1] page.

*NB: There is a bug with `@IBDesignable` when using external frameworks that prevents the view from rendering wihtin Interface Builder. Further reading can be found [here][2].*

#### Cocoapods

Add `pod 'UserTrackingButton', '~> 0.1'` to you `Podfile` and run `pod install`.

## Setup

To use UserTrackingButton from Interface Builder simply subclass a `UIView` component and set its class to `UserTrackingButton`. Connect the `mapView` outlet and you're done.

The same steps are required when adding the button in code:

```
let btn = UserTrackingButton(frame: trackingButtonFrame)
btn.mapView = self.mapView
self.view.addSubview(btn)
```
And there, you're done. The button handles the binding to user tracking state of the `MKMapView` instance.


[1]: https://github.com/Carthage/Carthage#if-youre-building-for-ios
[2]: https://openradar.appspot.com/23114017