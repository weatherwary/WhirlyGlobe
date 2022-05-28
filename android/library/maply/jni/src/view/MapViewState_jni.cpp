/*
 *  MapViewState_jni.cpp
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 3/17/15.
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

#import "View_jni.h"
#import "CoordSystem_jni.h"
#import "Geometry_jni.h"
#import "Renderer_jni.h"
#import "com_mousebird_maply_MapViewState.h"

using namespace WhirlyKit;
using namespace Maply;

template<> MapViewStateRefClassInfo *MapViewStateRefClassInfo::classInfoObj = NULL;

JNIEXPORT void JNICALL Java_com_mousebird_maply_MapViewState_nativeInit
  (JNIEnv *env, jclass cls)
{
	MapViewStateRefClassInfo::getClassInfo(env,cls);
}

JNIEXPORT void JNICALL Java_com_mousebird_maply_MapViewState_initialise
  (JNIEnv *env, jobject obj, jobject viewObj, jobject rendererObj)
{
	try
	{
		MapView *mapView = MapViewClassInfo::getClassInfo()->getObject(env,viewObj);
		SceneRendererGLES_Android *renderer = (SceneRendererGLES_Android *)SceneRendererInfo::getClassInfo()->getObject(env,rendererObj);
		if (!mapView || !renderer)
			return;

		MapViewStateRef *mapViewState = new MapViewStateRef(new Maply::MapViewState(mapView,renderer));

		if (mapViewState)
			MapViewStateRefClassInfo::getClassInfo()->setHandle(env,obj,mapViewState);
	}
	catch (...)
	{
		__android_log_print(ANDROID_LOG_VERBOSE, "Maply", "Crash in VectorInfo::initialise()");
	}
}
