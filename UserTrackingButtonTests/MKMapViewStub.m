//
//  MKMapViewStub.m
//  UserTrackingButton
//
//  Created by Mikko Välimäki on 16-07-04.
//  Copyright © 2016 Mikko Välimäki. All rights reserved.
//

#import "MKMapViewStub.h"

@implementation MKMapViewStub
{
    MKUserTrackingMode _userTrackingMode;
    MKUserLocation *_userLocation;
}

- (MKUserTrackingMode)userTrackingMode
{
    return _userTrackingMode;
}

- (MKUserLocation *)userLocation
{
    return _userLocation;
}

- (void)setupUserTrackingMode:(MKUserTrackingMode)userTrackingMode location:(MKUserLocation *)location
{
    _userTrackingMode = userTrackingMode;
    _userLocation = location;
}

@end

@implementation MKUserLocationStub

- (instancetype)initWithLocation:(nullable CLLocation *)location
{
    if (self = [super init])
    {
        if (location)
        {
            [self setValue:location forKey:@"location"];
        }
    }
    return self;
}

@end