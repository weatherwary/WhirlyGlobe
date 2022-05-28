/*
 *  SimplePoly.java
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

import android.graphics.Color;

import java.util.List;


/**
 * Extremely simple polygon class
 */
public class SimplePoly {

    /**
     * Creates an empty polygon
     */
    public SimplePoly() {
        initialise();
    }

    /**
     * Creates a polygon based on a texture, color, points and text coordinates
     */
    public SimplePoly(Texture inTexture, float[] color, List<Point2d> pts, List<Point2d> texCoords) {
        initialise(inTexture.getID(), color[0], color[1], color[2], color[3], pts.toArray(new Point2d[0]), texCoords.toArray(new Point2d[0]));
    }

    native void initialise(long texID, float red, float green, float blue, float alpha, Point2d[] pts, Point2d[] texCoords);

    public void finalize() {
        dispose();
    }

    /**
     * Adds the texture to the polygon
     * @param texture
     */
    public void addTexture(Texture texture) {
        addTextureNative(texture.getID());
    }

    /**
     * Adds the texture identifier.
     * @param texID
     */
    public native void addTextureNative(long texID);

    /**
     * Sets the color of the poly
     */
    void addColor(int color)
    {
        addColor(Color.red(color)/255.f,Color.green(color)/255.f,Color.blue(color)/255.f,Color.alpha(color)/255.f);
    }

    /**
     * Sets the color of the poy
     */
    public native void addColor(float r,float g,float b,float a);

    /**
     * Adds one point to the polygon definition
     * @param pt point to add.
     */
    public native void addPt(Point2d pt);

    /**
     * Adds a list of points to the polygon definition
     * @param pts list of points
     */
    public native void addPts(Point2d[] pts);

    /**
     * Changes one point in the polygon definition.
     * @param index the index of the point to change.
     * @param newPt the new point.
     */
    public native void setPt(int index, Point2d newPt);

    /**
     * Adds a new text coordinate
     * @param texCoord the text coordinate
     */
    public native void addTexCoord(Point2d texCoord);

    /**
     * Adds a list of text coordinates.
     * @param texCoord the list of coordinates.
     */
    public native void addTexCoords(Point2d[] texCoord);

    /**
     * Changes one text coordinate.
     * @param index the index of the coordinate to change
     * @param newTexCoord the next coordinate
     */
    public native void setTexCoord(int index, Point2d newTexCoord);

    static {
        nativeInit();
    }
    private static native void nativeInit();
    native void initialise();
    native void dispose();

    private long nativeHandle;
}
