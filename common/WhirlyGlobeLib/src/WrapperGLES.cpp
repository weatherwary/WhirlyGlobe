/*  WrapperGLES.cpp
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 12/18/13.
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

#import <string.h>
#import "WrapperGLES.h"

#ifdef __ANDROID__

bool hasVertexArraySupport = false;
bool hasMapBufferSupport = false;

#else

// On ios we have both
bool hasVertexArraySupport = true;
bool hasMapBufferSupport = true;

#endif
