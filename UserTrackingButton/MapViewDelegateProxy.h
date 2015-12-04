//
//  MapViewDelegateProxy.h
//  UserTrackingButton
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewDelegateProxy : NSObject<MKMapViewDelegate>

- (instancetype)initWithMapView:(MKMapView *)mapView target:(id<MKMapViewDelegate>)target;

@end
