/*
 *  FakeGeocentricDisplayAdapter_jni.cpp
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
#import "com_mousebird_maply_FakeGeocentricDisplayAdapter.h"

using namespace WhirlyKit;

template<> FakeGeocentricDisplayAdapterInfo *FakeGeocentricDisplayAdapterInfo::classInfoObj = NULL;

JNIEXPORT void JNICALL Java_com_mousebird_maply_FakeGeocentricDisplayAdapter_nativeInit
  (JNIEnv *env, jclass cls)
{
	FakeGeocentricDisplayAdapterInfo::getClassInfo(env,cls);
}

JNIEXPORT void JNICALL Java_com_mousebird_maply_FakeGeocentricDisplayAdapter_initialise
  (JNIEnv *env, jobject obj)
{
	try
	{
		FakeGeocentricDisplayAdapterInfo *classInfo = FakeGeocentricDisplayAdapterInfo::getClassInfo();
		FakeGeocentricDisplayAdapter *coordAdapter = new FakeGeocentricDisplayAdapter();
		classInfo->setHandle(env,obj,coordAdapter);
	}
	catch (...)
	{
		__android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in CoordSystemDisplayAdapter::initialise()");
	}
}

static std::mutex disposeMutex;

/*
 * Class:     com_mousebird_maply_CoordSystemDisplayAdapter
 * Method:    dispose
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_mousebird_maply_FakeGeocentricDisplayAdapter_dispose
  (JNIEnv *env, jobject obj)
{
	try
	{
		FakeGeocentricDisplayAdapterInfo *classInfo = FakeGeocentricDisplayAdapterInfo::getClassInfo();
        {
            std::lock_guard<std::mutex> lock(disposeMutex);
            FakeGeocentricDisplayAdapter *coordAdapter = classInfo->getObject(env,obj);
            if (!coordAdapter)
                return;
            delete coordAdapter;

            classInfo->clearHandle(env,obj);
        }
	}
	catch (...)
	{
		__android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in CoordSystemDisplayAdapter::dispose()");
	}
}
