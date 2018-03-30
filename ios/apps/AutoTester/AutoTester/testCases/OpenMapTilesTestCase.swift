//
//  OpenMapTilesTestCase.swift
//  AutoTester
//
//  Created by Stephen Gifford on 12/7/17.
//  Copyright © 2017 Saildrone. All rights reserved.
//

import Foundation

class OpenMapTilesTestCase: MaplyTestCase {
    
    override init() {
        super.init()
        
        self.name = "OpenMapTiles Test Case"
        self.captureDelay = 4
        self.implementations = [.map]
    }
    
    // Set up an OpenMapTiles display layer
    func setupLayer(_ baseVC: MaplyBaseViewController) -> MaplyQuadPagingLayer?
    {
        guard let path = Bundle.main.path(forResource: "SE_Basic", ofType: "json") else {
            return nil
        }
        guard let styleData = NSData.init(contentsOfFile: path) else {
            return nil
        }
        guard let styleSet = MapboxVectorStyleSet.init(json: styleData as Data!,
                                                       settings: MaplyVectorStyleSettings.init(scale: UIScreen.main.scale),
                                                       viewC: baseVC,
                                                       filter: nil) else {
            return nil
        }
        
        let tileInfo = MaplyRemoteTileInfo.init(baseURL: "http://public-mobile-data-stage-saildrone-com.s3-us-west-1.amazonaws.com/openmaptiles/{z}/{x}/{y}.png", ext: nil, minZoom: 0, maxZoom: 14)
        let tileSource = MaplyRemoteTileSource(info: tileInfo)
        
        if let tileSource = tileSource {
            let pageDelegate = MapboxVectorTilesPagingDelegate(tileSource: tileSource, style: styleSet, viewC: baseVC)
//            pageDelegate.tileParser?.debugLabel = true
//            pageDelegate.tileParser?.debugOutline = true
            if let pageLayer = MaplyQuadPagingLayer(coordSystem: MaplySphericalMercator(), delegate: pageDelegate) {
                pageLayer.flipY = false
                pageLayer.importance = 512*512;
                pageLayer.singleLevelLoading = true

                // Background layer supplies the background color
                if let backLayer = styleSet.layersByName!["background"] as? MapboxVectorLayerBackground? {
                    baseVC.clearColor = backLayer?.paint.color
                }

                return pageLayer
            }
        }
        return nil
    }
    
    override func setUpWithMap(_ mapVC: MaplyViewController) {
        mapVC.performanceOutput = true
        
        if let layer = setupLayer(mapVC) {
            mapVC.add(layer)
        }
    }
}
