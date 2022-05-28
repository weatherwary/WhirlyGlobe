/*
 *  Billboard.java
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

import android.graphics.Bitmap;
import android.graphics.Color;
import android.util.Size;

import java.util.ArrayList;
import java.util.List;


/**
 * Single billboard representation.
 * <br>
 * Billboards are oriented towards the user.
 * <br>
 * Fill this out and hand it over to the billboard layer to manage.
 */
public class Billboard {

	/**
     * Creates an empty billboard.
     */
    public Billboard() {
        initialise();
    }

    /**
     * @param center center in display coordinates
     */
    public native void setCenter(Point3d center);

    /**
     * @return center in display coordinates
     */
    public native Point3d getCenter();

    /**
     * @param size size (for selection)
     */
    public native void setSize(Point2d size);

    /**
     * @return Size (for selection)
     */
    public native Point2d getSize();

    /**
     * If set, this marker should be made selectable and it will be
     * if the selection layer has been set
     */
    public native void setSelectable(boolean selectable);

    /**
     * @return the selectable flag
     */
    public native boolean getSelectable();

	/**
     * @return The 2D polygonal description of what the billboard should be
     */
    public ScreenObject getScreenObject() {
        return screenObject;
    }

	/**
     * @param screenObject The 2D polygonal description of what the billboard should be
     */
    public void setScreenObject(ScreenObject screenObject) {
        this.screenObject = screenObject;
    }

	/**
     * Vertex attributes to apply to this billboard.
     * <br>
     * VertexAttribute objects are passed all the way to the shader.  Read that page for details on what they do.
     * <br>
     * The array of vertex attributes provided here will be copied onto all the vertices we create for the shader.  This means you can use these to do things for a single billboard in your shader.
     * @return vertex attributes to apply to this billboard.
     */
    public ArrayList<VertexAttribute> getVertexAttributes() {
        return vertexAttributes;
    }

	/**
     * @param vertexAttributes vertex attributes to apply to this billboard.
     */
    public void setVertexAttributes(ArrayList<VertexAttribute> vertexAttributes) {
        this.vertexAttributes = vertexAttributes;
    }

    /**
     * @return Unique ID for selection
     */
    public long getSelectID() {
        return selectID;
    }

    /**
     * @param selectID Unique ID for selection
     */
    public void setSelectID(long selectID){
        this.selectID = selectID;
    }


    public void flatten() {
        if (screenObject != null)
            flattenNative(screenObject);
        screenObject = null;
    }

    public native void flattenNative(ScreenObject screenObject);

    public void finalize()
    {
        dispose();
    }

    static
    {
        nativeInit();
    }
    private static native void nativeInit();
    native void initialise();
    native void dispose();
    private long nativeHandle;

    private long selectID = Identifiable.genID();
    private ScreenObject screenObject;
    private ArrayList<VertexAttribute> vertexAttributes = new ArrayList<>();
}
