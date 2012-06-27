C4MiOS_LocationManager
======================

Use this classe for get your current location, the placeMark of the current location or the placeMark of a coordinate.


Usage
-----

This class use the new IOS5 method for reverse geocoding and the old method for under versions.

The placeMark is a NSDictionary like this :

	{
	City = Marseille;
	Country = France;
	CountryCode = FR;
	FormattedAddressLines =     (
      "L'Autoroute du Littoral",
      "13002 Marseille",
      France
	);
	Name = "L'Autoroute du Littoral";
	State = "Provence-Alpes-C\U00f4te d'Azur";
	Street = "L'Autoroute du Littoral";
	SubAdministrativeArea = "Bouches-du-Rh\U00f4ne";
	SubLocality = "La Joliette";
	Thoroughfare = "L'Autoroute du Littoral";
	ZIP = 13002;
	location = "<+43.31018710,+5.36692820> +/- 100.00m (speed -1.00 mps / course -1.00) @ 16/11/11 17:40:17 heure normale de l\U2019Europe centrale";
	}

Method for ask a location or a placeMark

	- (void) getUserLocation;

Give the current location of the user, -(void)receiveUserLocation:(CLLocation*)_Location must be implemented in the delegate.

	- (void) getPlaceMarkFromCurrentLocation;

Give placeMark of the current position, -(void)receivePlaceMark:(NSDictionary*)_placeMark must be implemented in the delegate.

	- (void) getPlaceMarkFromCoordinate:(CLLocationCoordinate2D)_coordinate;

Give placeMark of the coordinate, -(void)receivePlaceMark:(NSDictionary*)_placeMark must be implemented in the delegate.

	- (void) getCoordinateFromAddrString:(NSString*)_addr;

Give the coordinate of an address -(void)receiveCoordinateFromLocation:(NSDictionary*)_coordinateDictionary must be implemented in the delegate.

	- (void) startLocationWithAccuracy:(CLLocationAccuracy)_accuracy;

Start a begins a continuous location, -(void)receiveUserLocation:(CLLocation*)_Location must be implemented in the delegate.

Type of CLLocationAccuracy

	kCLLocationAccuracyBestForNavigation
	kCLLocationAccuracyBest
	kCLLocationAccuracyNearestTenMeters
	kCLLocationAccuracyHundredMeters
	kCLLocationAccuracyKilometer
	kCLLocationAccuracyThreeKilometers

	- (void) stopLocation;

Stop the continuous location.

Delegate for the answer :

	- (void)receiveUserLocation:(CLLocation*)_Location;

	- (void)receivePlaceMark:(NSDictionary*)_placeMark; - (void)receiveError:(NSError*)_error;

	- (void)receiveCoordinateFromLocation:(NSDictionary*)_coordinateDictionary;

The dictionary returned is like this :

	{
  		accuracy = 8;
  		lat = 8;
  		long = 8;
  		statusCode = 200;
	}

^ statusCode ^ Description ^
|200 |No errors occurred; the address was successfully parsed and its geocode was returned. |
|300 |Unknow error |
|500 |A geocoding or directions request could not be successfully processed, yet the exact reason for the failure is unknown.|
|601|An empty address was specified in the HTTP q parameter. |
|602|No corresponding geographic location could be found for the specified address, possibly because the address is relatively new, or because it may be incorrect.|
|603|The geocode for the given address or the route for the given directions query cannot be returned due to legal or contractual reasons.|
|610|The given key is either invalid or does not match the domain for which it was given.|
|620|The given key has gone over the requests limit in the 24 hour period or has submitted too many requests in too short a period of time. If you're sending multiple requests in parallel or in a tight loop, use a timer or pause in your code to make sure you don't send the requests too quickly. |


^ accuracy ^ Description ^
|0 |Unknown accuracy. |
|1 |Country level accuracy. |
|2 |Region (state, province, prefecture, etc.) level accuracy. |
|3 |Sub-region (county, municipality, etc.) level accuracy. |
|4 |Town (city, village) level accuracy. |
|5 |Post code (zip code) level accuracy. | 	
|6 |Street level accuracy. |	
|7 |Intersection level accuracy. | 	
|8 |Address level accuracy. | 
|9 |Premise (building name, property name, shopping center, etc.) level accuracy. |	


Change Logs
-----------

### v1.0

First release