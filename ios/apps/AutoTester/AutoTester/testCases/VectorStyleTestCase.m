//
//  VectorStyleTestCase.m
//  AutoTester
//
//  Created by Steve Gifford on 8/12/16.
//  Copyright © 2016-2017 mousebird consulting.
//

#import "VectorStyleTestCase.h"
#import "AutoTester-Swift.h"

@implementation VectorStyleTestCase
{
    CartoDBLightTestCase *baseCase;
}

- (instancetype)init
{
    if (self = [super initWithName:@"Vector Style Test" supporting:MaplyTestCaseImplementationMap | MaplyTestCaseImplementationGlobe]) {
    }
    return self;
}

- (void)overlayCountryFile:(NSString *)name ext:(NSString *)ext viewC:(MaplyBaseViewController *)viewC
{
    MaplyVectorStyleSimpleGenerator *simpleStyle = [[MaplyVectorStyleSimpleGenerator alloc] initWithViewC:viewC];

    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    if(path) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0 error:nil];
        MaplyVectorObject *vecObj = [[MaplyVectorObject alloc] initWithGeoJSONDictionary:jsonDictionary];
        AddMaplyVectorsUsingStyle(@[vecObj],simpleStyle,viewC,MaplyThreadAny);
    }
}

- (void)setUpWithGlobe:(WhirlyGlobeViewController *)globeVC
{
    baseCase = [[CartoDBLightTestCase alloc]init];
    [baseCase setUpWithGlobe:globeVC];
    [globeVC animateToPosition:MaplyCoordinateMakeWithDegrees(-100.0, 40.0) time:1.0];
    
    [self overlayCountryFile:@"USA" ext:@"geojson" viewC:globeVC];
}

- (void)setUpWithMap:(MaplyViewController *)mapVC
{
    baseCase = [[CartoDBLightTestCase alloc]init];
    [baseCase setUpWithMap:mapVC];
    [mapVC animateToPosition:MaplyCoordinateMakeWithDegrees(-100.0, 40.0) time:1.0];

    [self overlayCountryFile:@"USA" ext:@"geojson" viewC:mapVC];
}

- (void)stop {
    [baseCase stop];
    [super stop];
}

@end
