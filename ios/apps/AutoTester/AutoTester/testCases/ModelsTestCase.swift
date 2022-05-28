//
//  ModelsTestCase.swift
//  AutoTester
//
//  Created by jmnavarro on 2/11/15.
//  Copyright 2015-2022 mousebird consulting.
//

import UIKit
import WhirlyGlobe

struct LocationInfo {
	var name: String
	var lat: Float
	var lon: Float
}

let locations = [
	LocationInfo (name: "Kansas City", lat: 39.1, lon: -94.58),
	LocationInfo (name: "Washington, DC", lat: 38.895111, lon: -77.036667),
	LocationInfo (name: "Manila", lat: 14.583333, lon: 120.966667),
	LocationInfo (name: "Moscow", lat: 55.75, lon: 37.616667),
	LocationInfo (name: "London", lat: 51.507222, lon: -0.1275),
	LocationInfo (name: "Caracas", lat: 10.5, lon: -66.916667),
	LocationInfo (name: "Lagos", lat: 6.453056, lon: 3.395833),
	LocationInfo (name: "Sydney", lat: -33.859972, lon: 151.211111),
	LocationInfo (name: "Seattle", lat: 47.609722, lon: -122.333056)
]

class ModelsTestCase: MaplyTestCase {

	override init() {
		super.init()
		
		self.name = "Models"
		self.implementations = [.globe]
	}

    let baseLayer = GeographyClassTestCase()

	override func setUpWithGlobe(_ globeVC: WhirlyGlobeViewController) {
		baseLayer.setUpWithGlobe(globeVC)

		let fullPath = Bundle.main.path(forResource: "cessna", ofType: "obj")
		if let fullPath = fullPath {
			let model = MaplyGeomModel(obj: fullPath)
			if let model = model {
				var modelInstances = [MaplyMovingGeomModelInstance]()
				let scaletMat = MaplyMatrix(scale: 1000.0/6371000.0)
				let rotMat = MaplyMatrix(angle: Double.pi/2.0, axisX: 1.0, axisY: 0.0, axisZ: 0.0)
				let localMat = rotMat.multiply(with: scaletMat)
				for loc in locations {
					let mInst = MaplyMovingGeomModelInstance()
					mInst.model = model
					mInst.transform = localMat
					let loc2d = MaplyCoordinateMakeWithDegrees(loc.lon, loc.lat)
					mInst.center = MaplyCoordinate3dMake(loc2d.x, loc2d.y, 10000)
					mInst.endCenter = MaplyCoordinate3dMake(loc2d.x+0.1, loc2d.y+0.1, 10000)
					mInst.duration = 100.0
					mInst.selectable = true
					modelInstances.append(mInst)

				}
                let h = Float(0.1)
                let desc = [
                    kMaplyEnable: true,
                    kMaplyViewerMinDist: 1.01,
                    kMaplyViewerMaxDist: 1.01 + h,
                    kMaplyViewableCenterX: 0.0,
                    kMaplyViewableCenterY: 0.0,
                    kMaplyViewableCenterZ: 0.0,
                ] as [AnyHashable:Any]
				globeVC.addModelInstances(modelInstances, desc: desc, mode: MaplyThreadMode.current)
				globeVC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-94.58, 39.1) ,time: 1.0)
				globeVC.height = h
			}
		}
	}

}
