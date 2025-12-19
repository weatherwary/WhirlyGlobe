# Vector Tile Polygon Handling

This document describes how WhirlyGlobe processes polygons from Mapbox Vector Tiles, including tessellation algorithms, performance optimizations, and handling of winding order and holes.

## Overview

WhirlyGlobe uses a multi-stage pipeline to process polygons from vector tiles:

1. **Parsing**: Extract polygon geometry from Protocol Buffer format
2. **Coordinate Transformation**: Convert from tile coordinates to geographic
3. **Tessellation**: Convert polygons to triangles for GPU rendering
4. **Batching**: Combine multiple polygons into efficient draw calls

## Data Structures

### VectorAreal

Polygons are represented by the `VectorAreal` class (`common/WhirlyGlobeLib/include/VectorData.h:187-211`):

```cpp
class VectorAreal : public VectorShape
{
    GeoMbr geoMbr;
    std::vector<VectorRing> loops;  // First = outer boundary, rest = holes
};
```

The first ring in `loops` is always the outer boundary. All subsequent rings are holes (interior rings).

## Tessellation

### Algorithm: GLUES (GLU ES)

WhirlyGlobe uses the **GLUES library** (`common/local_libs/glues/`) for tessellation, which is derived from SGI's reference GLU tessellator implementation by Eric Veach.

The algorithm is a **sweep line algorithm with ear clipping**, which:
- Handles complex polygons including self-intersecting edges
- Supports multiple contours (holes)
- Uses winding rules to determine interior/exterior regions
- Optionally applies Constrained Delaunay Triangulation for improved triangle quality

### Key Tessellation Functions

**Main entry points** (`common/WhirlyGlobeLib/src/Tesselator.cpp`):

```cpp
// Tessellate a single ring
void TesselateRing(const VectorRing &ring, VectorTrianglesRef tris);

// Tessellate multiple rings (outer boundary + holes)
void TesselateLoops(const std::vector<VectorRing> &loops, VectorTrianglesRef tris);
```

### Tessellation Process

The tessellation process (`Tesselator.cpp:60-138`):

1. **Create tessellator instance** with custom memory allocator
2. **Add contours** - each ring (outer + holes) is added as a separate contour
3. **Execute tessellation** with `TESS_WINDING_ODD` rule
4. **Extract triangles** from the tessellator output

```cpp
// Line 103: Execute tessellation
tessTesselate(tess, TESS_WINDING_ODD, TESS_POLYGONS, verticesPerTriangle, vertexSize, 0);
```

### Winding Rules

The tessellator supports multiple winding rules (`common/local_libs/glues/include/glues.h:41-48`):

| Rule | Description |
|------|-------------|
| `TESS_WINDING_ODD` | Interior if odd number of contours (default) |
| `TESS_WINDING_NONZERO` | Interior if winding number ≠ 0 |
| `TESS_WINDING_POSITIVE` | Interior if winding number > 0 |
| `TESS_WINDING_NEGATIVE` | Interior if winding number < 0 |
| `TESS_WINDING_ABS_GEQ_TWO` | Interior if |winding number| ≥ 2 |

WhirlyGlobe uses **`TESS_WINDING_ODD`** which correctly handles polygons with holes based on their winding order.

## Winding Order Handling

### Mapbox Vector Tile Specification

The Mapbox Vector Tile specification expects:
- **Outer rings**: Counter-clockwise (CCW) winding
- **Inner rings (holes)**: Clockwise (CW) winding

### Signed Area Calculation

Winding order is determined using the **shoelace formula** (`common/WhirlyGlobeLib/src/VectorData.cpp:29-52`):

```cpp
template <typename T, typename TRet, typename TInt>
TRet CalcLoopArea(const std::vector<T> &loop, size_t loopSize)
{
    TInt area = 0.0;
    for (unsigned int ii = 0; ii < maxIter; ii++)
    {
        const auto &p1 = loop[ii];
        const auto &p2 = loop[(ii+1) % loopSize];
        area += (TInt)p1.x() * (TInt)p2.y();
        area -= (TInt)p1.y() * (TInt)p2.x();
    }
    return (TRet)area;
}
```

**Interpretation**:
- **Positive area** → Counter-clockwise (CCW) → Outer boundary
- **Negative area** → Clockwise (CW) → Hole

### Automatic Handling

The `TESS_WINDING_ODD` rule automatically distinguishes between outer boundaries and holes based on their winding order. No explicit winding order normalization is required.

## Holes

### Representation

Holes are stored as additional rings in the `VectorAreal::loops` vector:

```cpp
// loops[0] = outer boundary
// loops[1..n] = holes (inner rings)
std::vector<VectorRing> loops;
```

### Parsing from Vector Tiles

During PBF parsing (`VectorTilePBFParser.cpp:497-575`), rings are extracted using command encoding:

- `MOVETO`: Starts a new ring (either outer or hole)
- `LINETO`: Adds points to the current ring
- `CLOSE`: Closes the current ring and adds it to `shape.loops`

```cpp
else if (cmd == SEG_CLOSE_MASKED)
{
    if (!tempRing.empty())
    {
        tempRing.emplace_back(firstCoord);  // Close the loop
        shape.loops.push_back(tempRing);    // Add to shape (outer or hole)
        tempRing.clear();
    }
}
```

### Tessellation with Holes

All rings are passed together to `TesselateLoops()`:

```cpp
// MapboxVectorStyleFill.cpp:155
TesselateLoops(ar->loops, trisRef);
```

The tessellator treats each contour independently and uses the winding rule to determine which regions are interior (filled) vs exterior (empty/hole).

## Performance Optimizations

### 1. Coordinate Scaling for Precision

Coordinates are scaled by `1e6` during tessellation to improve numerical precision (`Tesselator.cpp:51`):

```cpp
static const float PolyScale2 = 1e6;

// Scale during tessellation
tessRing.push_back(static_cast<TESSreal>((pt.x()-org.x()) * PolyScale2));
tessRing.push_back(static_cast<TESSreal>((pt.y()-org.y()) * PolyScale2));

// Unscale for output
tris->pts.push_back(Point3f(pos[0]/PolyScale2+org.x(), pos[1]/PolyScale2+org.y(), 0.0));
```

### 2. Local Coordinate Conversion

Before tessellation, geographic coordinates are converted to local coordinates to avoid floating-point precision issues near poles and at large scales (`MapboxVectorStyleFill.cpp:144-151`):

```cpp
// Convert to local to make tessellation work better (#1392)
for (auto &loop : ar->loops)
{
    for (auto &pt : loop)
    {
        pt = coordSys->geographicToLocal2(pt.cast<double>()).cast<float>();
    }
}
```

### 3. Duplicate Point Removal

Consecutive duplicate points and closing duplicates are removed before tessellation (`Tesselator.cpp:88-96`):

```cpp
// Skip closing duplicate
if (ii == ring.size()-1 && pt.x() == ring[0].x() && pt.y() == ring[0].y())
    continue;

// Skip consecutive duplicates
if (ii > 0) {
    const Point2f &prevPt = ring[ii-1];
    if (pt.x() == prevPt.x() && pt.y() == prevPt.y())
        continue;
}
```

### 4. Batching

Multiple polygons are combined into single drawable batches to reduce draw calls (`VectorManager.h`):

> "You do not want to create individual vector features on the globe one by one, that's too expensive. It needs to be batched and that's how we do this."

The `VectorManager::addVectors()` function batches multiple tessellated shapes:

```cpp
// MapboxVectorStyleFill.cpp:205
const SimpleIdentity vecID = styleSet->vecManage->addVectors(&tessShapes, vecInfo, tileInfo->changes);
```

### 5. Memory Allocation Optimization

The tessellator uses a custom bucket allocator with pre-allocated extra vertices (`Tesselator.cpp:71-78`):

```cpp
TESSalloc ma;
ma.memalloc = stdAlloc;
ma.memfree = stdFree;
ma.extraVertices = 256;  // Pre-allocate for intersection vertices
```

### 6. Origin-Relative Coordinates

Tessellation uses origin-relative coordinates to maximize floating-point precision (`Tesselator.cpp:79`):

```cpp
Point2f org = (loops[0])[0];  // Use first point as origin
// All coordinates relative to org during tessellation
tessRing.push_back(static_cast<TESSreal>((pt.x()-org.x()) * PolyScale2));
```

### 7. Heuristic-Based Memory Reservation

The PBF parser pre-allocates vectors based on layer byte size heuristics (`VectorTilePBFParser.cpp:151-161`):

```cpp
_layerKeys.reserve(layerKeyHeuristic(layerBytes));
_layerValues.reserve(layerValueHeuristic(layerBytes));
_featureTags.reserve(featureTagHeuristic(layerBytes));
_featureGeometry.reserve(featureGeometryHeuristic(layerBytes));
```

## Fill Rendering Pipeline

The complete polygon rendering flow (`MapboxVectorStyleFill.cpp:90-259`):

1. **Filter** shapes to areal (polygon) types only
2. **Convert** coordinates to local space
3. **Tessellate** each polygon (including holes)
4. **Create** VectorTriangles with tessellated geometry
5. **Apply** Mapbox style (color, opacity)
6. **Add** to VectorManager for batched rendering
7. **Optionally** create outline strokes

## Related Files

| File | Description |
|------|-------------|
| `common/WhirlyGlobeLib/src/Tesselator.cpp` | Tessellation wrapper |
| `common/WhirlyGlobeLib/include/Tesselator.h` | Tessellation API |
| `common/local_libs/glues/` | GLUES tessellation library |
| `common/WhirlyGlobeLib/src/VectorTilePBFParser.cpp` | Vector tile parsing |
| `common/WhirlyGlobeLib/src/MapboxVectorStyleFill.cpp` | Fill layer rendering |
| `common/WhirlyGlobeLib/include/VectorData.h` | Vector data structures |
| `common/WhirlyGlobeLib/src/VectorData.cpp` | Area calculations |
| `common/local_libs/clipper/` | Polygon clipping library |
