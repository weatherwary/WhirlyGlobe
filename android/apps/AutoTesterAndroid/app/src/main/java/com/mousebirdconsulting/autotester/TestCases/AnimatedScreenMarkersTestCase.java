package com.mousebirdconsulting.autotester.TestCases;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.mousebird.maply.ActiveObject;
import com.mousebird.maply.ComponentObject;
import com.mousebird.maply.GlobeController;
import com.mousebird.maply.MapController;
import com.mousebird.maply.BaseController;
import com.mousebird.maply.MarkerInfo;
import com.mousebird.maply.Point2d;
import com.mousebird.maply.RenderController;
import com.mousebird.maply.ScreenMarker;
import com.mousebirdconsulting.autotester.Framework.MaplyTestCase;
import com.mousebirdconsulting.autotester.R;

import java.util.ArrayList;

/**
 * Created by sjg on 5/23/16.
 */
public class AnimatedScreenMarkersTestCase extends MaplyTestCase implements ActiveObject
{
    BaseController controller;

    public AnimatedScreenMarkersTestCase(Activity activity) {
        super(activity, "Active Object", TestExecutionImplementation.Both);
        setDelay(1000);
    }

    private final MaplyTestCase baseCase = new GeographyClass(getActivity());

    @Override
    public boolean setUpWithMap(MapController mapVC) throws Exception {
        baseCase.setUpWithMap(mapVC);
        startMarkers(mapVC);
        mapVC.setPositionGeo(pos.getX(), pos.getY(), 2);
        return true;
    }

    @Override
    public boolean setUpWithGlobe(GlobeController globeVC) throws Exception {
        baseCase.setUpWithGlobe(globeVC);
        startMarkers(globeVC);
        globeVC.animatePositionGeo(pos.getX(), pos.getY(), 0.9, 1);
        return true;
    }

    @Override
    public void shutdown() {
        baseCase.shutdown();
        super.shutdown();
        controller = null;
    }

    MarkerInfo markerInfo;
    Bitmap icon;
    ComponentObject compObj = null;
    private final Point2d pos = Point2d.FromDegrees(-3.6704803, 40.5023056);

    // Change the marker every frame
    public boolean hasChanges() {
        return true;
    }

    // Move a marker to a random location every frame
    public void activeUpdate() {
        ArrayList<ScreenMarker> markers = new ArrayList<>();

        final Point2d off = Point2d.FromDegrees(Math.random(), Math.random());

        ScreenMarker marker = new ScreenMarker();
        marker.image = icon;
        marker.loc = pos.addTo(off);
        marker.size = new Point2d(128, 128);
        marker.rotation = Math.random() * 2.f * Math.PI;
        markers.add(marker);

        if (compObj != null) {
            controller.removeObject(compObj, RenderController.ThreadMode.ThreadCurrent);
            compObj = null;
        }
        compObj = controller.addScreenMarkers(markers, markerInfo, RenderController.ThreadMode.ThreadCurrent);
    }

    // Kick off the marker animation with an active object
    private void startMarkers(BaseController inController) {
        markerInfo = new MarkerInfo();
        icon = BitmapFactory.decodeResource(getActivity().getResources(), R.drawable.testtarget);

        controller = inController;
        controller.addActiveObject(this);
    }
}
