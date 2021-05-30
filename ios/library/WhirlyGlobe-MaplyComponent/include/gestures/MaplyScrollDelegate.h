//
//  Created by WeatherWary LLC
//  Copyright © WeatherWary LLC. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import "gestures/MaplyZoomGestureDelegate.h"

@interface MaplyScrollDelegate : MaplyZoomGestureDelegate

/// Create a pinch gesture and a delegate and wire them up to the given UIView
+ (MaplyScrollDelegate *)scrollDelegateForView:(UIView *)view mapView:(Maply::MapView_iOSRef)mapView;

@end
