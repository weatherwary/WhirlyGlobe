/*  ShapeSphere.java
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
 */
package com.mousebird.maply;

/** Display a sphere at the given location with the given radius.
 */
public class ShapeSphere extends Shape {

    /**
     * Construct an empty sphere.  Be sure to fill in the fields.
     */
    public ShapeSphere() {
        initialise();
    }

    public void finalize() {
        dispose();
    }

    /** Center of the sphere
      * <br>
     *  The x and y coordinates correspond to longitude and latitude and are in geographic (radians).
     */
    public native void setLoc(Point2d loc);

    /** Center of the sphere
     * <br>
     *  The x and y coordinates correspond to longitude and latitude and are in geographic (radians).
     *  The Z value is in display coordinates.  For that globe that's based on a radius of 1.0.  Scale accordingly.
     */
    public native void setLoc3d(Point3d loc);

    /** Offset height above the globe in display units.
     * <br>
     * This is the height above the globe for the center of the sphere.  It's also in display units, like the radius.
     */
    public native void setHeight(float height);

    /** Radius of the sphere in display units.
     * <br>
     * This is the radius of the sphere, but not in geographic.  It's in display units.
     * Display units for the globe are based on a radius of 1.0.  Scale accordingly.
     * For the map, display units typically run from -PI to +PI, depending on the coordinate system.
     */
    public native void setRadius(float radius);

    /**
     * Number of samples around the horizontal and vertical of the sphere.
     */
    public native void setSamples(int sampleX,int sampleY);

    static {
        nativeInit();
    }
    private static native void nativeInit();
    native void initialise();
    native public void dispose();
}
