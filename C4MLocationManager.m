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
 
#import "C4MLocationManager.h"

@implementation C4MLocationManager

@synthesize locationManager;
@synthesize mDelegate;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(ifReverse == NO)
    {
        if([mDelegate respondsToSelector:@selector(receiveUserLocation:)])
            [mDelegate receiveUserLocation:newLocation];
        
        if(ifStart==NO)
        {
            [manager stopUpdatingLocation];
            lm.delegate = nil;
            [lm release];
        }
    }
    else
    {
        [self getPlaceMarkFromCoordinate:newLocation.coordinate];
        [manager stopUpdatingLocation];
        lm.delegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if(ifStart==NO)
    {
        [manager stopUpdatingLocation];
        lm.delegate = nil;
        [lm release];
    }    
    if([mDelegate respondsToSelector:@selector(receiveError:)])
        [mDelegate receiveError:error];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSMutableDictionary* dicPlaceMark = [[NSMutableDictionary alloc] initWithDictionary:[placemark addressDictionary]];
   /* if([mDelegate respondsToSelector:@selector(receivePlaceMark:)])
        [mDelegate receivePlaceMark:dicPlaceMark];*/
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePlaceMark" object:dicPlaceMark];
    [dicPlaceMark release];
    [lm release];
    [MKgeoCoder autorelease];
}

// this delegate is called when the reversegeocoder fails to find a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    if([mDelegate respondsToSelector:@selector(receiveError:)])
        [mDelegate receiveError:error];
    [lm release];
    [MKgeoCoder autorelease];
}


-(void) getUserLocation
{
    ifStart = NO;
    ifReverse = NO;
    if(!lm)
    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    [lm startUpdatingLocation];
}

-(void) getPlaceMarkFromCurrentLocation
{
    ifReverse = YES;
    if(!lm)
        lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    [lm startUpdatingLocation];
}

-(void) getPlaceMarkFromCoordinate:(CLLocationCoordinate2D)_coordinate
{
    if([[[UIDevice currentDevice] systemVersion] intValue] < 5.0)
    {
     //   MKReverseGeocoder *geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:_coordinate];
        MKgeoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:_coordinate];
        MKgeoCoder.delegate = self;
        [MKgeoCoder start];
    }
    else
    {
        CLLocation* loc = [[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
        
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark * placemark in placemarks) 
            {
                NSMutableDictionary* dicPlacemark = [[NSMutableDictionary alloc] initWithDictionary:placemark.addressDictionary];
                [dicPlacemark setObject:placemark.location forKey:@"location"];
               /* if([mDelegate respondsToSelector:@selector(receivePlaceMark:)])
                    [mDelegate receivePlaceMark:dicPlacemark];*/
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePlaceMark" object:dicPlacemark];
                [dicPlacemark release];
            }    
        }];
        [geoCoder release];
        [loc release];
        [lm release];
        
    }
}

- (void) startLocationWithAccuracy:(CLLocationAccuracy)_accuracy
{
    ifStart = YES;
    ifReverse = NO;

    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = _accuracy;
    [lm startUpdatingLocation];
}

- (void) stopLocation
{
    if(lm)
    {
        [lm stopUpdatingLocation];
        lm.delegate = nil;
        [lm release];
    }
}


- (void) getCoordinateFromAddrString:(NSString*)_addr
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", 
[_addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
    
    NSMutableDictionary* coordinateDictionary = [[NSMutableDictionary alloc] init];
    if([listItems count]>=4)
    {
        [coordinateDictionary setObject:[listItems objectAtIndex:0] forKey:@"statusCode"];
        [coordinateDictionary setObject:[listItems objectAtIndex:1] forKey:@"accuracy"];
        [coordinateDictionary setObject:[listItems objectAtIndex:1] forKey:@"lat"];
        [coordinateDictionary setObject:[listItems objectAtIndex:1] forKey:@"long"];
    }
    else
    {
        [coordinateDictionary setObject:@"300" forKey:@"statusCode"];
    }
    if([mDelegate respondsToSelector:@selector(receiveCoordinateFromLocation:)])
        [mDelegate receiveCoordinateFromLocation:coordinateDictionary];
    [coordinateDictionary release];
    
}
 
@end
