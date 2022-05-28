/*
 *  Light.java
 *  WhirlyGlobeLib
 *
 *  Created by jmnavarro
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
package com.mousebird.maply;

/**
 * This is a simple material definition.
 */
public class Material {

    public Material() {
        initialise();
    }

    public void finalize() {
        dispose();
    }

    /**
     * @param ambient Ambient material color
     */
    public native void setAmbient(Point4d ambient);

    /**
     * @param diffuse Diffuse material color
     */
    public native void setDiffuse(Point4d diffuse);

    /**
     * @param specular Specular component of material color
     */
    public native void setSpecular(Point4d specular);

    /**
     * @param specularExponent Specular exponent used in lighting
     */
    public native void setSpecularExponent(float specularExponent);

    static
    {
        nativeInit();
    }
    private static native void nativeInit();
    native void initialise();
    native void dispose();
    private long nativeHandle;
}
