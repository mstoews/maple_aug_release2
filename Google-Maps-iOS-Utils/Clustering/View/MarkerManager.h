//
//  MarkerManager.h
//  Maple
//
//  Created by Murray Toews on 8/22/18.
//  Copyright © 2018 Murray Toews. All rights reserved.
//

#ifndef MarkerManager_h
#define MarkerManager_h

#import <Foundation/Foundation.h>
@import CoreLocation;
#import "GMUClusterItem.h"
#import <GoogleMaps/GoogleMaps.h>


@interface MarkerManager: NSObject

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic, strong) GMSMarker *marker;

@end

#endif /* MarkerManager_h */
