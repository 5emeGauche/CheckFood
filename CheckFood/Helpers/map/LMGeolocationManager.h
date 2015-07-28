//
//  LMGeolocationManager.h
//  jobaproxim
//
//  Created by Marouene Tekaya on 07/03/13.
//  Copyright (c) 2013 ILYES BELFEKIH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
/**
 Protocol that notify the callback of geocoding request
 */
@protocol LMGeolocationManagerDelegate <NSObject>
@optional
/**
 Method that notify the callback of geocoding request
 @param response the response of the request
 */
-(void)getPositionFromAddressFinished:(id)response;
@end
/**
 The manager for google api requests and geolocation
 */
@interface LMGeolocationManager : NSObject<CLLocationManagerDelegate>{
    CLLocationManager * _locationManager;
    CLAuthorizationStatus authorizationStatus;
    BOOL _hasLocatedPosition;
    CLLocation * _location;
    __weak NSObject<LMGeolocationManagerDelegate> * _delegate;
}
/**
 The location manager
 */
@property (nonatomic,strong) CLLocationManager * locationManager;
/**
 The Geocoder
 */
@property (nonatomic,strong) CLGeocoder * geoCoder;
/**
 Boolean set to YES if the manager has located the position of the device
 */
@property (nonatomic,assign) BOOL hasLocatedPosition;
/**
 The device location
 */
@property (nonatomic,strong) CLLocation * location;
/**
 The delegate of the manager
 */
@property (nonatomic,weak) NSObject<LMGeolocationManagerDelegate> * delegate;
/**
 This is the method that returns a reference to the singleton object
 @returns  The reference of the JAPGeolocationManager
 */
+(LMGeolocationManager *)sharedManager;
/**
 the method that return YES if the geolocation is authorized
 @Returns YES if the geolocation is authorized
 */
-(BOOL)isGeolocationAuthorized;
/**
 The method that start geolocation
 */
-(void)startLocationUpdates;
/**
 The method that stop geolocation
 */
-(void)stopLocationUpdates;

@end
