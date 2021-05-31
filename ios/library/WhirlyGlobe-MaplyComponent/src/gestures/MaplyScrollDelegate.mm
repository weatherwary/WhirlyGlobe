/*  MaplyScrollDelegateMap.mm
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford & WeatherWary LLC on 5/30/21.
 *  Copyright 2011-2021 mousebird consulting & WeatherWary LLC
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

#import "gestures/MaplyScrollDelegate.h"
#import "SceneRenderer.h"
#import "MaplyZoomGestureDelegate_private.h"
#import "MaplyAnimateTranslation.h"
#import "ViewWrapper.h"
using namespace WhirlyKit;
using namespace Maply;

@implementation MaplyScrollDelegate
{
    /// If we're zooming, where we started
    bool zooming;
    float startZ;
    Point2f startingPoint;
    Point3d startingGeoPoint;
}

+ (MaplyScrollDelegate *)scrollDelegateForView:(UIView *)view mapView:(MapView_iOSRef)mapView
{
  MaplyScrollDelegate *scrollDelegate = [[MaplyScrollDelegate alloc] initWithMapView:mapView];
    UIPanGestureRecognizer *scrollRecognizer;
      scrollRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:scrollDelegate action:@selector(scrollAction:)];
    scrollRecognizer.delegate = scrollDelegate;
    scrollRecognizer.allowedScrollTypesMask = UIScrollTypeMaskAll;
    scrollRecognizer.minimumNumberOfTouches = 2;
    scrollDelegate.gestureRecognizer = scrollRecognizer;
  [view addGestureRecognizer:scrollRecognizer];
    scrollDelegate.gestureRecognizer = scrollRecognizer;
  return scrollDelegate;
}


// Called for scroll actions
- (void)scrollAction:(id)sender
{
    UIPanGestureRecognizer *pan = sender;
    UIView<WhirlyKitViewWrapper> *wrapView = (UIView<WhirlyKitViewWrapper> *)pan.view;
    SceneRenderer *sceneRenderer = wrapView.renderer;
    
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
        {
          
            // Store the starting Z for comparison
            startZ = self.mapView->getLoc().z();
            
            //calculate center between touches, in screen and map coords
            CGPoint t0 = [pan locationInView:pan.view];
            startingPoint.x() = t0.x;
            startingPoint.y() = t0.y;
            Eigen::Matrix4d modelTrans = self.mapView->calcFullMatrix();
            Point2f frameSize = sceneRenderer->getFramebufferSizeScaled();
            self.mapView->pointOnPlaneFromScreen(startingPoint, &modelTrans, frameSize, &startingGeoPoint, true);

            self.mapView->cancelAnimation();
            [[NSNotificationCenter defaultCenter] postNotificationName:kZoomGestureDelegateDidStart object:self.mapView->tag];
            zooming = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (zooming)
            {
              Point3d curLoc = self.mapView->getLoc();
              CGPoint translation = [pan translationInView:pan.view];
              // Make the translation smaller so that the zooming is smoother 
              double zoomInc = 1.0 + translation.y / 50.0;
              if (zoomInc < 0.0) {
                zoomInc = -1.0/zoomInc;
              }
              double newZ = startZ/zoomInc;
              if (self.minZoom >= self.maxZoom || (self.minZoom < newZ && newZ < self.maxZoom))
              {
                  MapView testMapView(*(self.mapView));

                  Point3d newLoc(curLoc.x(), curLoc.y(), newZ);
                  
                  testMapView.setLoc(newLoc,false);

                  // calculate scalepoint offset in screenspace
                  Eigen::Matrix4d modelTrans = testMapView.calcFullMatrix();
                  auto frameSizeScaled = sceneRenderer->getFramebufferSizeScaled();
                  Point2f currentScalePointScreenLoc = testMapView.pointOnScreenFromPlane(startingGeoPoint, &modelTrans, frameSizeScaled);
                  Point2f screenOffset(startingPoint.x() - currentScalePointScreenLoc.x(),
                      startingPoint.y() - currentScalePointScreenLoc.y());

                  //calculate a new map center to maintain scalepoint in place on screen
                  Point2f newMapCenterPoint((wrapView.frame.size.width/2.0) - screenOffset.x(),
                      (wrapView.frame.size.height/2.0) - screenOffset.y());
                  Point3d newCenterGeoPoint;
                  testMapView.pointOnPlaneFromScreen(newMapCenterPoint, &modelTrans, frameSizeScaled, &newLoc, true);
                  newLoc = self.mapView->coordAdapter->displayToLocal(newLoc);
                  newLoc.z() = newZ;

                  testMapView.setLoc(newLoc, false);
                  Point3d newCenter;
                  if (MaplyGestureWithinBounds(bounds,newLoc,sceneRenderer,&testMapView,&newCenter))
                  {
                      self.mapView->setLoc(newCenter, true);
                  }
              }
              [pan setTranslation:CGPointZero inView:pan.view];
              startZ = newZ;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            if (zooming)
            {
              [[NSNotificationCenter defaultCenter] postNotificationName:kZoomGestureDelegateDidEnd object:self.mapView->tag];
                zooming = NO;
            }
        break;
      default:
            break;
    }
}

@end
