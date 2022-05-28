/*
 *  GeoCoordSystem_jni.cpp
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 3/18/15.
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
 *
 */

#import <jni.h>
#import "CoordSystem_jni.h"
#import "com_mousebird_maply_GeoCoordSystem.h"

using namespace WhirlyKit;

JNIEXPORT void JNICALL Java_com_mousebird_maply_GeoCoordSystem_nativeInit
  (JNIEnv *env, jclass cls)
{
}

JNIEXPORT void JNICALL Java_com_mousebird_maply_GeoCoordSystem_initialise
  (JNIEnv *env, jobject obj)
{
	try
	{
		GeoCoordSystem *coordSystem = new GeoCoordSystem();
		CoordSystemRefClassInfo::getClassInfo()->setHandle(env,obj,new CoordSystemRef(coordSystem));
	}
	catch (...)
	{
		__android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in GeoCoordSystem::initialise()");
	}
}
