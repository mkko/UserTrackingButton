//
//  MapViewDelegateProxy.h
//  UserTrackingButton
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewDelegateProxy : NSObject<MKMapViewDelegate>

- (nonnull instancetype)initWithMapView:(nonnull MKMapView *)mapView target:(nonnull id<MKMapViewDelegate>)target;

@property (nonatomic, readonly, weak) id<MKMapViewDelegate> orignalDelegate;
@property (nonatomic, readonly, nonnull) id<MKMapViewDelegate> target;
@property (nonatomic, readonly, nonnull) MKMapView *mapView;

@end
