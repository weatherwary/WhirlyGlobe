//
//  ActiveObjectTestCase.m
//  AutoTester
//
//  Created by Steve Gifford on 9/9/16.
//  Copyright © 2016-2017 mousebird consulting.
//

#import "ActiveObjectTestCase.h"
#import "AutoTester-Swift.h"

@interface SimpleActiveObject : MaplyActiveObject
@end

@implementation SimpleActiveObject
{
    MaplyComponentObject *compObj;
    MaplyTexture *tex;
}

- (nonnull instancetype)initWithViewController:(MaplyBaseViewController *__nonnull)viewC image:(MaplyTexture *)inTex
{
    self = [super initWithViewController:viewC];
    tex = inTex;
    
    return self;
}

- (bool)hasUpdate
{
    return true;
}

- (void)updateForFrame:(void *)frameInfo
{
    // Delete it
    if (compObj)
    {
        [self.viewC removeObjects:@[compObj] mode:MaplyThreadCurrent];
        compObj = nil;
    }
    
    MaplyCoordinate coord = MaplyCoordinateMakeWithDegrees(-1 + 2*drand48(), -1 + 2*drand48());
    MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
    marker.loc = coord;
    marker.image = tex;
    marker.size = CGSizeMake(64,64);
    marker.layoutImportance = MAXFLOAT;
    compObj = [self.viewC addScreenMarkers:@[marker] desc:@{kMaplyFade: @(NO)} mode:MaplyThreadCurrent];
}

@end

@implementation ActiveObjectTestCase
{
    SimpleActiveObject *activeObject;
    CartoDBLightTestCase *baseCase;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.name = @"Active Object Test Case";
        self.implementations = MaplyTestCaseImplementationMap | MaplyTestCaseImplementationGlobe;
    }
    
    return self;
}

- (void)setupActiveObject:(MaplyBaseViewController *)viewC
{
    MaplyTexture *tex = [viewC addTexture:[UIImage imageNamed:@"beer-24@2x.png"] desc:nil mode:MaplyThreadCurrent];
    
    activeObject = [[SimpleActiveObject alloc] initWithViewController:viewC image:tex];
    
    [viewC addActiveObject:activeObject];
}

- (void)setUpWithGlobe:(WhirlyGlobeViewController *)globeVC
{
    baseCase = [[CartoDBLightTestCase alloc] init];
    [baseCase setUpWithGlobe:globeVC];
    
    [self setupActiveObject:globeVC];
}

- (void)setUpWithMap:(MaplyViewController *)mapVC
{
    baseCase = [[CartoDBLightTestCase alloc] init];
    [baseCase setUpWithMap:mapVC];

    [self setupActiveObject:mapVC];
}

- (void)stop
{
    if (baseCase)
    {
        [baseCase stop];
        baseCase = nil;
    }
}

@end
