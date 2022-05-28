//
//  MegaMarkersTestCase.m
//  AutoTester
//
//  Created by jmnavarro on 2/11/15.
//  Copyright 2015-2022 mousebird consulting.
//

#import "MegaMarkersTestCase.h"
#import "VectorsTestCase.h"

@implementation MegaMarkersTestCase

- (instancetype)init
{
	if (self = [super init]) {
		self.name = @"Mega Markers";
		self.implementations = MaplyTestCaseImplementationMap | MaplyTestCaseImplementationGlobe;
	}
	return self;
}

- (void) insertMegaMarkers: (MaplyBaseViewController*) theView
{
	const int numMegaMarkerImages = 1500;
	const int numMegaMarkers = 1000;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
	^{
		// Make up a few markers
		NSMutableArray *markerImages = [[NSMutableArray alloc] init];
		for (unsigned int ii = 0; ii < numMegaMarkerImages; ii++) {
			UIImage *image = [self randomImage];
			MaplyTexture *tex = [theView addTextureToAtlas:image mode:MaplyThreadCurrent];
			[markerImages addObject:tex];
		}

		NSMutableArray *markers = [[NSMutableArray alloc] init];
		for (unsigned int ii = 0; ii < numMegaMarkers; ii++) {
			MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
			marker.image = [markerImages objectAtIndex:random()%numMegaMarkerImages];
			marker.size = CGSizeMake(16,16);
			marker.loc = MaplyCoordinateMakeWithDegrees(drand48()*360-180, drand48()*140-70);
			marker.layoutImportance = MAXFLOAT;
			//marker.layoutImportance = 1.0;
			[markers addObject:marker];
		}

		[theView addScreenMarkers:markers desc:@{kMaplyClusterGroup: @(0)} mode:MaplyThreadCurrent];
	});
}

// Generate a random image for testing
- (UIImage *)randomImage
{
	float scale = [UIScreen mainScreen].scale;

	CGSize size = CGSizeMake(16*scale, 16*scale);
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	CGRect rect = CGRectMake(1, 1, size.width-2, size.height-2);
	CGContextAddEllipseInRect(ctx, rect);
	[[UIColor whiteColor] setStroke];
	CGContextStrokePath(ctx);
	[[UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0] setFill];
	CGContextFillEllipseInRect(ctx, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

-(void)setUpWithGlobe:(WhirlyGlobeViewController *)globeVC
{
	VectorsTestCase * baseView = [[VectorsTestCase alloc]init];
	[baseView setUpWithGlobe:globeVC];
	[self insertMegaMarkers: (MaplyBaseViewController*)globeVC];
}

-(void)setUpWithMap:(MaplyViewController *)mapVC
{
	VectorsTestCase * baseView = [[VectorsTestCase alloc]init];
	[baseView setUpWithMap: mapVC];
	[self insertMegaMarkers: (MaplyBaseViewController*)mapVC];
}

@end
