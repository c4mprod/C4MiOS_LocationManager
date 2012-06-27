/*******************************************************************************
 * This file is part of the C4MiOS_LocationManager project.
 * 
 * Copyright (c) 2012 C4M PROD.
 * 
 * C4MiOS_LocationManager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * C4MiOS_LocationManager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with C4MiOS_LocationManager. If not, see <http://www.gnu.org/licenses/lgpl.html>.
 * 
 * Contributors:
 * C4M PROD - initial API and implementation
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKReverseGeocoder.h>

//@interface LocationManager : NSObject



@protocol C4MLocationManagerDelegate

@optional
- (void)receiveUserLocation:(CLLocation*)_Location;
- (void)receivePlaceMark:(NSDictionary*)_placeMark;
- (void)receiveError:(NSError*)_error;
- (void)receiveCoordinateFromLocation:(NSDictionary*)_coordinateDictionary;


@end

@interface C4MLocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	CLLocationManager *locationManager;
    CLLocationManager *lm;
    MKReverseGeocoder *MKgeoCoder;
    BOOL ifStart;
    BOOL ifReverse;
    NSObject<C4MLocationManagerDelegate>* mDelegate;
}

@property (nonatomic, assign) NSObject<C4MLocationManagerDelegate>* mDelegate;
@property (nonatomic, retain) CLLocationManager *locationManager;  

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
didFailWithError:(NSError *)error;


// Use THIS method
- (void) getUserLocation;
- (void) getPlaceMarkFromCurrentLocation;
- (void) getPlaceMarkFromCoordinate:(CLLocationCoordinate2D)_coordinate;
- (void) getCoordinateFromAddrString:(NSString*)_addr;

/*
Type of CLLocationAccuracy
 kCLLocationAccuracyBestForNavigation;
 kCLLocationAccuracyBest;
 kCLLocationAccuracyNearestTenMeters;
 kCLLocationAccuracyHundredMeters;
 kCLLocationAccuracyKilometer;
 kCLLocationAccuracyThreeKilometers;
*/
- (void) startLocationWithAccuracy:(CLLocationAccuracy)_accuracy;
- (void) stopLocation;

@end

