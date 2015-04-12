import luxe.Input;
import luxe.Quaternion;
import luxe.Sprite;
import luxe.Transform;
import luxe.utils.Maths;
import luxe.Sprite;
import luxe.Visual;
import luxe.Color;
import luxe.Vector;
import phoenix.geometry.Geometry;
import phoenix.geometry.QuadGeometry;

import geometry.TriangleFanGeometry;
import options.TriangleFanGeometryOptions;

/*typedef IntersectionResult = {
	var x:Float;
	var y:Float;
	var t:Float;
}*/

class Main extends luxe.Game {
	var walls:Array<Sprite> = new Array<luxe.Sprite>();
	var cachedVertexPositions:Array<Vector> = new Array<Vector>();

	var wallColour:Color = new Color(0.25, 0.25, 0.25, 1);
	var lightColour:Color = new Color(0.9, 0.9, 0.1, 1);

	var mousePos:Vector = new Vector();
	var edges:QuadGeometry;

	var mainLight:SightLight;

	override function ready() {
		// create a bunch of random obstacles
		for(n in 0...10) {
			var w:Float = Maths.random_float(8, 128);
			var h:Float = Maths.random_float(8, 128);

			walls.push(new Sprite({
				geometry: Luxe.draw.box({
					x: w / -2,
					y: h / -2,
					w: w,
					h: h
				}),
				color: wallColour,
				pos: Luxe.utils.geometry.random_point_in_unit_circle().multiplyScalar(Luxe.screen.h / 2).add(Luxe.screen.mid),
				depth: 0,
				rotation_z: Maths.random_float(0, 360)
			}));
		}

		// create the main SightLight!
		mainLight = new SightLight({
			centre: Luxe.screen.mid,
			colour: lightColour,
			depth: -1
		});
		mainLight.updateEdgesFromSprites(walls);

		trace(Luxe.camera.viewport);

	} //ready

	override function onkeyup( e:KeyEvent ) {

		if(e.keycode == Key.escape) {
			Luxe.shutdown();
		}
		else if(e.keycode == Key.key_r) {
			// randomly re-arrange the walls
			for(wall in walls) {
				wall.pos = Luxe.utils.geometry.random_point_in_unit_circle().multiplyScalar(Luxe.screen.h / 2).add(Luxe.screen.mid);
				wall.rotation_z = Maths.random_float(0, 360);
			}

			// update the light
			mainLight.updateEdgesFromSprites(walls);

			// re-draw it
			mainLight.centre = mousePos;
		}

	} //onkeyup

	override function onmousemove(e:MouseEvent) {
		// get the mouse position
		mousePos = Luxe.camera.screen_point_to_world(e.pos);

		// update the whole shebang
		mainLight.centre = mousePos;
	}

	override function update(dt:Float) {
	} //update

} //Main
