package com.mousebird.maply;

/**
 * Selected Objects are returned by the selection manager when the system wants a
 * selection return.
 *
 */
public class SelectedObject
{
    public SelectedObject() {
        initialise();
    }

    /**
     * Return the ID of the object that was selected.
     */
    native long getSelectID();

    /**
     * The Java-side object selected.
     */
    public Object selObj = null;

    /**
     * The distance in 3D from the tap point to the selected object.
     */
    native public double getDistIn3d();

    /**
     * Distance in screen space from the tap to the selected object.
     */
    native public double getScreenDist();

    /**
     * Set if this return was part of a cluster.  This means the user tapped
     * on a cluster and we're just returning everything.
     */
    native public boolean isPartOfCluster();

    /**
     * Get the cluster group, if the object is part of a cluster
     */
    native public int getClusterGroup();

    /**
     * Get the ID of the object representing the cluster, if any
     */
    native public long getClusterID();

    /**
     * Get the geographic location of the cluster
     */
    native public Point2d getClusterCenter();

    public void finalize() {
        dispose();
    }

    static {
        nativeInit();
    }
    private static native void nativeInit();
    native void initialise();
    native void dispose();

    @SuppressWarnings("unused")     // Used by JNI
    private long nativeHandle;
}
