/*  GreatCircle_Android.h
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 3/15/19.
 *  Copyright 2011-2022 mousebird consulting
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#ifdef __ANDROID__
#import <jni.h>
#endif
#import "Maply_jni.h"
#import "WhirlyGlobeLib.h"

namespace WhirlyKit
{

/** Great Circles are actually just 3D linear features.
    This is a simple representation for the Java side.
 */
struct GreatCircle_Android : public Shape
{
    // Convert to a 3D linear feature
    Linear *asLinear(const CoordSystemDisplayAdapter *coordAdapter) const;

    // Start/end geographic points
    Point2d startPt = { 0.0, 0.0 };
    Point2d endPt = { 0.0, 0.0 };
    // Height above the globe (or map)
    double height = 0.0;
    // If set, we'll sample dynamically
    double samplingEps = 0.001;
    // If set, we'll sample statically
    int sampleNum = 0;
};

}
