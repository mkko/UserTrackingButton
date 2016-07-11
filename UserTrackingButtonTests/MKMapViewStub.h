//
//  MKMapViewStub.h
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 16-07-04.
//  Copyright © 2016 Mikko Välimäki. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapViewStub : MKMapView

- (void)setupUserTrackingMode:(MKUserTrackingMode)userTrackingMode location:(nullable MKUserLocation *)location;

@end

@interface MKUserLocationStub : MKUserLocation

- (nonnull instancetype)initWithLocation:(nullable CLLocation *)location;

@end