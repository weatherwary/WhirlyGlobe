/*
 *  MapView.java
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 3/13/15.
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

import java.util.ArrayList;
import java.util.GregorianCalendar;

/**
 * Base class for 2D and 3D views.
 * 
 * @author sjg
 *
 */
public class View 
{
	CoordSystemDisplayAdapter coordAdapter = null;
	
	/**
	 * Return the coordinate adapter used by this view.
	 * The coordinate adapter manages transformation from the local coordinate system
	 * to display coordinates and vice versa.
	 * @return
	 */
	CoordSystemDisplayAdapter getCoordAdapter()
	{
		return coordAdapter;
	}

	// Filled in by the subclasses
	protected View clone()
	{
		return null;
	}

	// Filled in by the subclasses
	public void animate() 
	{
	}

	// Subclasses override
	public boolean isAnimating()
	{
		return false;
	}

	// Filled in by the subclass
	public void cancelAnimation() 
	{
	}

	// Filled in by the subclass
	public ViewState makeViewState(RenderController renderer)
	{
		return null;
	}
	
	// For objects that want to know when the view changes (every time it does)
	interface ViewWatcher
	{
		public void viewUpdated(View view);
	}

	double lastUpdated;

	/**
	 * When the view was last changed.
     */
	public double getLastUpdatedTime()
	{
		return lastUpdated;
	}

	ArrayList<ViewWatcher> watchers = new ArrayList<ViewWatcher>();
	
	// Add a watcher for callbacks on each and every view related change
	void addViewWatcher(ViewWatcher watcher)
	{
		synchronized (this) {
			watchers.add(watcher);
		}
	}
	// Remove an object that was watching view changes
	void removeViewWatcher(ViewWatcher watcher)
	{
		synchronized (this) {
			watchers.remove(watcher);
		}
	}
	// Let everything know we changed the view
	void runViewUpdates()
	{
		ArrayList<ViewWatcher> theWatchers = null;
		synchronized (watchers) {
			theWatchers = new ArrayList<ViewWatcher>(watchers);
		}
		for (ViewWatcher watcher: theWatchers)
			watcher.viewUpdated(this);
		lastUpdated = GregorianCalendar.getInstance().getTimeInMillis() / 1000.0;
	}

	// Return the current model & view matrix combined (but not projection)
	native Matrix4d calcModelViewMatrix();

	// Return the height for a given map scale
	public native double heightForMapScale(double scale,double frameSizeX,double frameSizeY);

	// Returns the map zoom for a given latitude
	public native double currentMapZoom(double frameSizeX,double frameSizeY,double latitude);

	// Returns the map scale
	public native double currentMapScale(double frameSizeX,double frameSizeY);

	static
	{
		nativeInit();
	}
	private static native void nativeInit();
	protected long nativeHandle;
}
