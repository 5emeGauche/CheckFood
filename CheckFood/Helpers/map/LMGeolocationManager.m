//
//  JAPGeolocationManager.m
//  jobaproxim
//
//  Created by Marouene Tekaya on 07/03/13.
//  Copyright (c) 2013 ILYES BELFEKIH. All rights reserved.
//

#import "LMGeolocationManager.h"
#import "PXSingleton.h"

@interface LMGeolocationManager ()
@end

@implementation LMGeolocationManager

@synthesize locationManager = _locationManager;
@synthesize hasLocatedPosition = _hasLocatedPosition;
@synthesize location = _location;
@synthesize delegate = _delegate;

#pragma mark - Private methods

#pragma mark - Public methods

+(LMGeolocationManager *) sharedManager PXSINGLETON(LMGeolocationManager)

-(BOOL)isGeolocationAuthorized{
   // authorizationStatus = [self.locationManager authorizationStatus];
    return (authorizationStatus == kCLAuthorizationStatusAuthorized);
}

-(void)startLocationUpdates{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc]init];

    }
    self.locationManager.delegate=self;
    [self.locationManager startUpdatingLocation];
}

-(void)pauseLocationUpdates{
    [self.locationManager pausesLocationUpdatesAutomatically];

}

-(void)stopLocationUpdates{
    [self.locationManager stopUpdatingLocation];
}



#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    self.hasLocatedPosition =YES;
    self.location = newLocation;
    
    [[LMGeolocationManager sharedManager]stopLocationUpdates];
    
}

- (void)locationManager:(CLLocationManager *)manager
didUpdateLocations:(NSArray *)locations {

    self.hasLocatedPosition =YES;
    self.location = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    authorizationStatus = status;
}

@end
