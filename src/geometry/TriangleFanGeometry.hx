package geometry;

import luxe.utils.Maths;
import luxe.Vector;
import phoenix.Batcher;
import luxe.Color;
import phoenix.geometry.Vertex;
import phoenix.geometry.Geometry;
import options.TriangleFanGeometryOptions;

class TriangleFanGeometry extends Geometry {
    public var centre:Vector;
    public var fan:Array<Vector>;

	public function new( ?options : TriangleFanGeometryOptions ) {

		super(options);

		if(options == null) {
			return;
		}

		if(options.color == null)  { options.color  = new Color(); }

		if(options.centre != null) {
			centre = options.centre;
		} else {
			throw "TriangleFanGeometry must have a centre and a fan!";
		}
		if(options.fan != null) {
			fan = options.fan;
		} else {
			throw "TriangleFanGeometry must have a centre and a fan!";
		}

		set(options);

	} //newrr

	private function buildFan() {
        for(f in fan) {
            var fanVert:Vertex = new Vertex(f.clone(), color);
            fanVert.uv.uv0.set_uv(0,0);
            add(fanVert);
        }
	}

	public function set(options:Dynamic) {

		primitive_type = PrimitiveType.triangle_fan;
		immediate = options.immediate;

	} //set

	public function redraw() {
		vertices.splice(0, vertices.length);

        var centreVert:Vertex = new Vertex(centre.clone(), color);
        centreVert.uv.uv0.set_uv(0,0);
        add(centreVert);

        buildFan();
	}


} //LineGeometry