package options;

import luxe.options.GeometryOptions;
import luxe.Vector;

typedef TriangleFanGeometryOptions = {
    > GeometryOptions,

    var centre:Vector;
    var fan:Array<Vector>;

} // TriangleFanGeometryOptions