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
@synthesize mIdentifier;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    C4MLog(@"");
    if(ifReverse == NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveUserLocation" object:newLocation];
        
        if(ifStart==NO)
        {
            [manager stopUpdatingLocation];
            lm.delegate = nil;
           /* [lm release];
            lm = nil;*/
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
    C4MLog(@"");
    if(ifStart==NO)
    {
        [manager stopUpdatingLocation];
        lm.delegate = nil;
        [lm release];
        lm = nil;
    }    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveError" object:error];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
     NSMutableDictionary* dicPlaceMark = [[NSMutableDictionary alloc] initWithDictionary:[placemark addressDictionary]];
    NSDictionary* dict;
    if([mGetPlaceMarkIdentifier count] > 0 )
    {
        dict = [mGetPlaceMarkIdentifier objectAtIndex:0];
        [dicPlaceMark setObject:[dict objectForKey:@"identifier"] forKey:@"identifierKey"];
    }
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePlaceMark" object:dicPlaceMark];
    [dicPlaceMark release];
    [lm release];
    lm = nil;
    [MKgeoCoder autorelease];
    if([mGetPlaceMarkIdentifier count] > 0 )
    {
        [mGetPlaceMarkIdentifier removeObjectAtIndex:0];
    }
    if([mGetPlaceMarkIdentifier count] > 0 )
    {
        NSDictionary* dic = [mGetPlaceMarkIdentifier objectAtIndex:0];
        CLLocation* location = [dic objectForKey:@"location"];
        [self getPlaceMarkFromCoordinate:location.coordinate];
    }
}

// this delegate is called when the reversegeocoder fails to find a placemark
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSMutableDictionary* dictionaryError = [NSMutableDictionary dictionaryWithCapacity:2];
    NSDictionary* dict;
    if([mGetPlaceMarkIdentifier count] > 0 )
    {
        dict = [mGetPlaceMarkIdentifier objectAtIndex:0];
        [dictionaryError setObject:[dict objectForKey:@"identifier"] forKey:@"identifier"];
    }
    [dictionaryError setObject:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveError" object:error];

    [lm release];
    lm = nil;
    [MKgeoCoder autorelease];
    if([mGetPlaceMarkIdentifier count] > 0 )
    {
        [mGetPlaceMarkIdentifier removeObjectAtIndex:0];
    }
    if([mGetPlaceMarkIdentifier count] > 0 )
    {
        NSDictionary* dic = [mGetPlaceMarkIdentifier objectAtIndex:0];
        CLLocation* location = [dic objectForKey:@"location"];
        [self getPlaceMarkFromCoordinate:location.coordinate];
    }
}


-(void) getUserLocation
{
    C4MLog(@"");
    ifStart = NO;
    ifReverse = NO;
    if(!lm)
    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    [lm startUpdatingLocation];
}

- (void) getPlaceMarkFromCurrentLocation
{
    C4MLog(@"");
    ifReverse = YES;
    if(!lm)
        lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    NSLog(@"lm retain count : %d",lm.retainCount);
    lm.desiredAccuracy = kCLLocationAccuracyBest;
    [lm startUpdatingLocation];
}

-(void) getPlaceMarkFromCoordinate:(CLLocationCoordinate2D)_coordinate
{
    C4MLog(@"");
    NSDictionary* dict;
    if([mGetPlaceMarkIdentifier count] > 0 )
    {
         dict = [mGetPlaceMarkIdentifier objectAtIndex:0];
    }
    else
    {
        dict = nil;
    }
    if([[[UIDevice currentDevice] systemVersion] intValue] < 5.0)
    {
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
                if(dict != nil )
                {
                    [dicPlacemark setObject:[dict objectForKey:@"identifier"] forKey:@"identifierKey"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePlaceMark" object:dicPlacemark];
                [dicPlacemark release];
            }    
        }];
        [geoCoder release];
        [loc release];
        [lm release];
        lm = nil;
        if([mGetPlaceMarkIdentifier count] > 0 )
        {
            [mGetPlaceMarkIdentifier removeObjectAtIndex:0];
        }
        if([mGetPlaceMarkIdentifier count] > 0 )
        {
            NSDictionary* dic = [mGetPlaceMarkIdentifier objectAtIndex:0];
            CLLocation* location = [dic objectForKey:@"location"];
            [self getPlaceMarkFromCoordinate:location.coordinate];
        }
    }
}

- (void) startLocationWithAccuracy:(CLLocationAccuracy)_accuracy
{
    C4MLog(@"");
    ifStart = YES;
    ifReverse = NO;

    lm = [[CLLocationManager alloc] init];
    lm.delegate = self;
    lm.desiredAccuracy = _accuracy;
    [lm startUpdatingLocation];
}

- (void) stopLocation
{
    C4MLog(@"");
    if(lm)
    {
        [lm stopUpdatingLocation];
        lm.delegate = nil;
        [lm release];
        lm = nil;
    }
}


- (void) getCoordinateFromAddrString:(NSString*)_addr
{
    NSDictionary* dict = [mGetCoordinateIdentifier objectAtIndex:0];
    NSString* identifier = [dict objectForKey:@"identifier"];
    if([[[UIDevice currentDevice] systemVersion] intValue] < 5.0)
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
            [coordinateDictionary setObject:[listItems objectAtIndex:2] forKey:@"lat"];
            [coordinateDictionary setObject:[listItems objectAtIndex:3] forKey:@"long"];
        }
        else
        {
            [coordinateDictionary setObject:@"300" forKey:@"statusCode"];
        }
        [coordinateDictionary setObject:identifier forKey:@"identifierKey"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getCoordinationFromAddrString" object:coordinateDictionary];
        [coordinateDictionary release];
    }
    else 
    {
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        [geocoder geocodeAddressString:_addr completionHandler:^(NSArray *placemarks, NSError *error)
         {  
             NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
             [dic setObject:identifier forKey:@"identifierKey"];
             if(error)
             {
                 NSLog(@"error : %@",error.localizedDescription);
                 [dic setObject:error forKey:@"error"];
             }
             else 
             {
                 NSLog(@"placemarks : %@",placemarks);
                 [dic setObject:placemarks forKey:@"placemarks"];
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:@"getCoordinationFromAddrString" object:dic];
             [dic release];
         }];
    }
    [mGetCoordinateIdentifier removeObjectAtIndex:0];
    if([mGetCoordinateIdentifier count]>0)
    {
        NSDictionary* dic = [mGetCoordinateIdentifier objectAtIndex:0];
        [self getCoordinateFromAddrString:[dic objectForKey:@"addr"]];
    }
}

static C4MLocationManager *sharedInstance = nil;
// Get the shared instance and create it if necessary.
+ (C4MLocationManager *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[C4MLocationManager alloc] init];
        }
    }
    return sharedInstance;
}

#pragma mark -
#pragma mark public method
+ (void)getPlaceMarkFromCurrentLocation
{
    C4MLocationManager* loc = [C4MLocationManager sharedInstance];
    [loc getPlaceMarkFromCurrentLocation];
}
 
+ (void) getUserLocation
{
    C4MLocationManager* loc = [C4MLocationManager sharedInstance];
    [loc getUserLocation];
}

+ (void) getCoordinationFromAddrString:(NSString*)_addr withIdentifier:(NSString*)_identifier
{
    C4MLocationManager* loc = [C4MLocationManager sharedInstance];
    if(!loc->mGetCoordinateIdentifier)
        loc->mGetCoordinateIdentifier = [[NSMutableArray alloc] init];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:_addr, @"addr",_identifier, @"identifier", nil];
    [loc->mGetCoordinateIdentifier addObject:dic];
    loc.mIdentifier = _identifier;
    if([loc->mGetCoordinateIdentifier count] <= 1)
        [loc getCoordinateFromAddrString:_addr];
}

+ (void) getPlaceMarkFromCoordinate:(CLLocationCoordinate2D)_coordinate withIdentifier:(NSString*)_identifier
{
    C4MLocationManager* loc = [C4MLocationManager sharedInstance];
    if(!loc->mGetPlaceMarkIdentifier)
        loc->mGetPlaceMarkIdentifier = [[NSMutableArray alloc] init];
    CLLocation* location = [[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:location, @"location",_identifier, @"identifier", nil];
    [loc->mGetPlaceMarkIdentifier addObject:dic];
    [location release];
    loc.mIdentifier = _identifier;
    if([loc->mGetPlaceMarkIdentifier count] <= 1)
        [loc getPlaceMarkFromCoordinate:_coordinate];
}

+ (void) startLocationWithAccuracy:(CLLocationAccuracy)_accuracy
{
    C4MLocationManager* loc = [C4MLocationManager sharedInstance];
    [loc startLocationWithAccuracy:_accuracy];
}
+ (void) stopLocation
{
    C4MLocationManager* loc = [C4MLocationManager sharedInstance];
    [loc stopLocation];
}

@end
