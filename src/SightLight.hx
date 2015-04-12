import haxe.ds.StringMap;
import luxe.Sprite;
import phoenix.geometry.Geometry;
import geometry.TriangleFanGeometry;
import luxe.Color;
import luxe.Transform;
import luxe.Vector;
import options.SightLineOptions;
import luxe.Entity;
import phoenix.Batcher;
import phoenix.Shader;

class SightLight extends Entity {
	public var geometry(default, null):TriangleFanGeometry;
	@:isVar public var shader(default, set):Shader;
	@:isVar public var colour(default, set):Color;
	@:isVar public var depth(default, set):Float;
	@:isVar public var visible(default, set):Bool;
	@:isVar public var group(default, set):Int = 0;

	@:isVar public var centre(default, set):Vector;
	private var fan:Array<Vector>;

	private var edges:Array<SightEdge> = new Array<SightEdge>();

	public function new(options:SightLineOptions, ?_pos_info:haxe.PosInfos) {
		if(options == null) {
			throw "SightLight need non-null options!";
		}

		// create the entity
		super(options, _pos_info);

		// set various options
		if(options.shader != null) { shader = options.shader; }

		if(options.colour != null) { colour = options.colour; }
		else { colour = new Color(); }

		if(options.depth != null) { depth = options.depth; }
		else { depth = 0; }

		if(options.visible != null) { visible = options.visible; }
		else { visible = true; }

		if(options.group != null) { group = options.group; }

		if(options.centre != null) { centre = options.centre; }
		else { centre = new Vector(); }

		fan = new Array<Vector>();

		var _batcher:Batcher = null;
		if(options.batcher != null) { _batcher = options.batcher; }
		else { _batcher = Luxe.renderer.batcher; }

		var _geomId:String = name + ".geom";

		// now create the geometry
		geometry = new TriangleFanGeometry({
			centre: centre,
			fan: fan,
			color: colour,
			depth: depth,
			id: _geomId,
			batcher: _batcher
		});
	}

	override function ondestroy() {
		// drop the geometry
		if(geometry != null && geometry.added) {
			geometry.drop(true);
		}
		geometry = null;
	}

	function set_shader(_s:Shader) {
		if(geometry != null && geometry.shader != _s) {
			geometry.shader = _s;
		}
		return shader = _s;
	}

	function set_colour(_c:Color) {
		if(colour != null && geometry != null) {
			geometry.color = _c;
		}
		return colour = _c;
	}

	function set_depth(_d:Float) {
		if(geometry != null) {
			geometry.depth = _d;
		}
		return depth = _d;
	}

	function set_visible(_v:Bool) {
		if(geometry != null) {
			geometry.visible = _v;
		}
		return visible = _v;
	}

	function set_group(_g:Int) {
		if(geometry != null) {
			geometry.group = _g;
		}
		return group = _g;
	}

	// whenever the user updates the light's
	// position with "sightLight.centre = ..."
	// everything will be updated
	// perhaps this should be offloaded to let the user when to take the processing hit?
	function set_centre(_c:Vector) {
		recalculate();

		if(geometry != null) {
			geometry.centre = _c;
			geometry.fan = fan;
			geometry.redraw();
		}

		return centre = _c;
	}

	// internal support function to get a list of unique points out of list of edges
	private function getUniquePoints(_edges:Array<SightEdge>) {
		var points:Array<Vector> = new Array<Vector>();
		for(edge in _edges) {
			points.push(edge.a);
			points.push(edge.b);
		}

		var set:StringMap<Bool> = new StringMap<Bool>();
		return points.filter(function(_v:Vector):Bool {
			var key = _v.x + "," + _v.y;
			if(set.exists(key)) { return false; }
			set.set(key, true);
			return true; 
		});
	}

	// use this function to recalculate the triangle fan of the lights
	// by projecting rays towards every unique geometry point of interest
	// it may be rather expensive. You've been warned.
	private function recalculate() {
		if(geometry == null) {
			return;
		}

		// get all angles
		var points:Array<Vector> = getUniquePoints(edges);
		var angles:Array<Float> = new Array<Float>();
		for(point in points) {
			var angle:Float = Math.atan2(point.y - centre.y, point.x - centre.x);
			angles.push(angle - 0.00001);
			angles.push(angle);
			angles.push(angle + 0.00001);
		}

		// sort the angles so that we always go in one direction
		angles.sort(function(x:Float, y:Float):Int {
			if(x > y) return 1;
			else if(x < y) return -1;
			return 0;
		});

		// cast a ray toward each point
		var intersections:Array<Vector> = new Array<Vector>();
		for(angle in angles) {
			var closestIntersect:IntersectionResult = null;
			var point:Vector = new Vector(Math.cos(angle), Math.sin(angle)).add(centre);

			for(edge in edges) {
				var intersection:IntersectionResult = getIntersection(centre, point, edge.a, edge.b);
				if(intersection != null && (closestIntersect == null || intersection.t < closestIntersect.t)) {
					closestIntersect = intersection;
				}
			}
			if(closestIntersect != null) {
				intersections.push(new Vector(closestIntersect.x, closestIntersect.y));
			}
		}


		// to close the triangle fan we need to return to the start
		if(intersections.length > 0) {
			intersections.push(intersections[0]);
		}
		if(intersections.length < 2) {
			visible = false;
		}

		fan = intersections;
	}

	// allow the user to submit a list of sprites to build the complete list of edges from them
	// these edges will be used in the lighting calculation---without calling this function,
	// nothing will be drawn
	// use the includeViewport to include the screen viewport (which you _probably_ want, or things will look weird)
	public function updateEdgesFromSprites(sprites:Array<Sprite>, includeViewport:Bool=true) {
		// clear the edge list
		edges.splice(0, edges.length);

		for(sprite in sprites) {
			for(edge in 0...4) {
				edges.push(SightEdge.fromQuad(sprite.geometry, edge));
			}
		}

		if(includeViewport) {
			var minX:Float = Luxe.camera.viewport.x;
			var minY:Float = Luxe.camera.viewport.y;
			var maxX:Float = Luxe.camera.viewport.x + Luxe.camera.viewport.w;
			var maxY:Float = Luxe.camera.viewport.y + Luxe.camera.viewport.h;
			edges.push(new SightEdge(new Vector(minX, minY), new Vector(maxX, minY)));
			edges.push(new SightEdge(new Vector(maxX, minY), new Vector(maxX, maxY)));
			edges.push(new SightEdge(new Vector(maxX, maxY), new Vector(minX, maxY)));
			edges.push(new SightEdge(new Vector(minX, maxY), new Vector(minX, minY)));
		}
	}

	// not sure what this does, just copied it from Visual.hx
	override function set_parent_from_transform(_parent:Transform) {
		super.set_parent_from_transform(_parent);
		if(geometry != null) {
			geometry.transform.parent = _parent;
		}
	}

	// function to find the intersection of two lines
	// taken pretty much verbatim from http://ncase.me/sight-and-light/
	function getIntersection(rayStart:Vector, rayEnd:Vector, segmentStart:Vector, segmentEnd:Vector):IntersectionResult {
		// ray in parametric form: Point + Direction * T1
		var r_px:Float = rayStart.x;
		var r_py:Float = rayStart.y;
		var r_dx:Float = rayEnd.x - rayStart.x;
		var r_dy:Float = rayEnd.y - rayStart.y;

		// segment in parametric form: Point + Direction * T2
		var s_px = segmentStart.x;
		var s_py = segmentStart.y;
		var s_dx = segmentEnd.x - segmentStart.x;
		var s_dy = segmentEnd.y - segmentStart.y;

		// Are they parallel? If so, no intersect
		var r_mag:Float = Math.sqrt(r_dx*r_dx+r_dy*r_dy);
		var s_mag:Float = Math.sqrt(s_dx*s_dx+s_dy*s_dy);
		if(r_dx/r_mag==s_dx/s_mag && r_dy/r_mag==s_dy/s_mag) { // Directions are the same.
			return null;
		}

		// SOLVE FOR T1 & T2
		// r_px+r_dx*T1 = s_px+s_dx*T2 && r_py+r_dy*T1 = s_py+s_dy*T2
		// ==> T1 = (s_px+s_dx*T2-r_px)/r_dx = (s_py+s_dy*T2-r_py)/r_dy
		// ==> s_px*r_dy + s_dx*T2*r_dy - r_px*r_dy = s_py*r_dx + s_dy*T2*r_dx - r_py*r_dx
		// ==> T2 = (r_dx*(s_py-r_py) + r_dy*(r_px-s_px))/(s_dx*r_dy - s_dy*r_dx)
		var T2:Float = (r_dx*(s_py-r_py) + r_dy*(r_px-s_px)) / (s_dx*r_dy - s_dy*r_dx);
		var T1:Float = (s_px+s_dx*T2-r_px) / r_dx;

		// Must be within parametic whatevers for RAY/SEGMENT
		if(T1 < 0) return null;
		if(T2 < 0 || T2 > 1) return null;

		// Return the POINT OF INTERSECTION
		return {
			x: r_px+r_dx*T1,
			y: r_py+r_dy*T1,
			t: T1
		};
	}
}

typedef IntersectionResult = {
	var x:Float;
	var y:Float;
	var t:Float;
}

class SightEdge {
	public var a:Vector;
	public var b:Vector;

	public function new(_a:Vector, _b:Vector) {
		a = _a;
		b = _b;
	}

	public static function fromQuad(quad:Geometry, faceNdx:Int) {
		var next:Int = faceNdx + 1;
		if(next >= 4) { next = 0; }
		return new SightEdge(
			new Vector(quad.vertices[faceNdx].pos.x, quad.vertices[faceNdx].pos.y).transform(quad.transform.world.matrix),
			new Vector(quad.vertices[next].pos.x, quad.vertices[next].pos.y).transform(quad.transform.world.matrix));
	}
}