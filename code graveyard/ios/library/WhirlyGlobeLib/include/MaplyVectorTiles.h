/*
 *  MaplyVectorTiles.h
 *  WhirlyGlobe-MaplyComponent
 *
 *  Created by Steve Gifford on 1/3/14.
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

#import <UIKit/UIKit.h>
#import "MaplyTileSource.h"
#import "MaplyBaseViewController.h"
#import "MaplyVectorStyle.h"

/** A Maply Vector Tiles database contains tiled vector data that
    can be displayed using styles contained within the database.
    The database will act as a paging delegate and is usually hooked
    up to a MaplyPagingLayer to do its thing.
  */
@interface MaplyVectorTiles : NSObject<MaplyPagingDelegate>

/** 
    Parse a color in #rrggbbaa format out of a string.
  */
+ (nonnull UIColor *)ParseColor:(NSString *__nonnull)colorStr;
+ (nonnull UIColor *)ParseColor:(NSString *__nonnull)colorStr alpha:(CGFloat)alpha;

/** 
    Kick off a maply vector tiles database from a remote URL.
    
    Creating a vector tiles database from a remote URL is a multi-stage process.  It requires a couple of network fetches first before we can safely start the db.  This runs through that process, creating the tile source and then calling the block when it's done.  It's up to the caller to provide a block that creates the paging layer and adds it to the view controller.
    
    @param jsonURL The URL for the top level JSON description of this whole mess.
    
    @param cacheDir A path to the cache directory.
    
    @param viewC The view controller to create the objects in.
    
    @param callbackBlock The block that gets called (on the main thread) when the construction succeeds or fails.
  */
+ (void)StartRemoteVectorTiles:(NSString *__nonnull)jsonURL cacheDir:(NSString *__nonnull)cacheDir viewC:(NSObject<MaplyRenderControllerProtocol> *__nonnull)viewC block:(void (^__nonnull)(MaplyVectorTiles *__nullable vecTiles))callbackBlock;

/** 
    Initialize with a local tiles database and a view controller to display to.
    
    This will start up a maply vector tiles object reading from the given database and building objects in the given view controller.
    
    The vector database will respond to the MaplyPagingDelegate and pull in tiles as needed for display.
  */
- (nullable instancetype)initWithDatabase:(NSString *__nonnull)tilesDB viewC:(NSObject<MaplyRenderControllerProtocol> *__nonnull)viewC;

/** 
    Initialize with a JSON tile spec, which specifies where the tiles come from and other values.
    
    Initialize a tile database with a JSON tile spec, which gives us remote tile locations, min and max levels and other useful values.
    
    @param jsonSpec The tile spec in NSDictionary form.  Presumably it was JSON.
    
    @param styles The styles dictionary.  Presumably we just fetched this remotely.
    
    @param viewC The view controller we'll use to create objects.
  */
- (nullable instancetype)initWithTileSpec:(NSDictionary *__nonnull)jsonSpec styles:(NSDictionary *__nonnull)styles viewC:(NSObject<MaplyRenderControllerProtocol> *__nonnull)viewC;

/// The minimum level this database covers
@property (nonatomic,assign) int minLevel;

/// The maximum level this database covers
@property (nonatomic,assign) int maxLevel;

/// The view controller the vector database paging builds its objects in
@property (nonatomic,weak,nullable) NSObject<MaplyRenderControllerProtocol> *viewC;

/// Settings that control how objects are built with relation to tiles
@property (nonatomic,strong,nullable) MaplyVectorStyleSettings *settings;

/// Individual layers parsed out of the vector tiles database
@property (nonatomic,readonly,nullable) NSArray *layerNames;

/// An array of the style dictionaries.
/// Style dictionaries are used internally to style the vector data.
@property (nonatomic,readonly,nonnull) NSArray *styles;

/// Set the cache dir for network fetched tiles.
/// If we're fetching tiles over the network we'll look here first.  Set it to nil to turn off caching.
@property (nonatomic,strong,nullable) NSString *cacheDir;

/// If set, all vectors created are selectable.
/// Keeping track of vectors for selection can be expensive.  If you're not going to ever select them, there's no need to keep them around.
/// Off by default.
@property (nonatomic) bool selectable;

@end
