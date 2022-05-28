//
//  LoftedPolysTestCase.m
//  AutoTester
//
//  Created by jmnavarro on 3/11/15.
//  Copyright 2015-2022 mousebird consulting.
//

#import "LoftedPolysTestCase.h"
#import "VectorsTestCase.h"

@implementation LoftedPolysTestCase
{
    VectorsTestCase *baseLayer;
}

- (instancetype)init
{
	if (self = [super init]) {
		self.name = @"Lofted Polys";
        self.implementations = MaplyTestCaseImplementationGlobe;
	}
	return self;
}

// Or maybe the USA.
-(void) addLoftedPolysSpain: (WhirlyGlobeViewController*) globeVC
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"USA" ofType:@"geojson" inDirectory:nil];
	if (path) {
		NSData *jsonData = [NSData dataWithContentsOfFile:path];
		if (jsonData) {
			MaplyVectorObject *wgVecObj = [MaplyVectorObject VectorObjectFromGeoJSON:jsonData];
			NSString *vecName = [[wgVecObj attributes] objectForKey:@"ADMIN"];
			wgVecObj.attributes[@"title"] = vecName;
			[globeVC addLoftedPolys:@[wgVecObj]
				desc:@{
					kMaplyLoftedPolyHeight: @(0.1),
					kMaplyLoftedPolyOutlineColor: [UIColor whiteColor],
					kMaplyDrawPriority: @(kMaplyLoftedPolysDrawPriorityDefault),
					kMaplyColor: [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.7]
				}
				mode:MaplyThreadAny];
		}
	}
}

-(void)setUpWithGlobe:(WhirlyGlobeViewController *)globeVC
{
	baseLayer = [[VectorsTestCase alloc]init];
    [baseLayer setUpWithGlobe:globeVC];
	[self addLoftedPolysSpain:globeVC];
    [globeVC animateToPosition:MaplyCoordinateMakeWithDegrees(-100.0, 40.0) time:1.0];
}

@end
