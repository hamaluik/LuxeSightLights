import phoenix.geometry.QuadGeometry;
import luxe.Input;
import luxe.Quaternion;
import luxe.Sprite;
import luxe.Transform;
import luxe.utils.Maths;
import luxe.Sprite;
import luxe.Visual;
import luxe.Color;
import luxe.Vector;
import phoenix.Batcher;
import luxe.Parcel;
import phoenix.geometry.Geometry;
import phoenix.geometry.QuadGeometry;
import phoenix.RenderTexture;
import geometry.TriangleFanGeometry;
import options.TriangleFanGeometryOptions;
import phoenix.Shader;

class Main extends luxe.Game {
	var walls:Array<Sprite> = new Array<luxe.Sprite>();
	var cachedVertexPositions:Array<Vector> = new Array<Vector>();

	var wallColour:Color = new Color(0.25, 0.25, 0.25, 1);
	var lightColour:Color = new Color(0.9, 0.9, 0.1, 1);

	var mousePos:Vector = new Vector();
	var edges:QuadGeometry;

	var mainLight:SightLight;

	var lightTexture:RenderTexture;
	var lightBatcher:Batcher;
	var lightOverlay:Visual;
	var lightShader:Shader;

	var parcelLoaded:Bool = false;

	override function ready() {
		// load the parcel
		Luxe.loadJSON("assets/parcel.json", function(jsonParcel) {
			var parcel = new Parcel();
			parcel.from_json(jsonParcel.json);

			// show a loading bar
			new luxe.ParcelProgress({
				parcel: parcel,
				oncomplete: assetsLoaded
			});
			
			// start loading!
			parcel.load();
		});
	} //ready

	function assetsLoaded(_) {
		// get the light shader
		lightShader = Luxe.resources.find_shader("assets/blur_frag.glsl|assets/blur_vert.glsl");
		lightShader.set_float('kernelSize', 0.01);

		// create a render target for the lights
		lightTexture = new RenderTexture(Luxe.resources, new Vector(1024, 1024));
		lightBatcher =  Luxe.renderer.create_batcher({
			name: 'light_batcher',
			no_add: true
		});
		lightBatcher.view.viewport = Luxe.camera.viewport;

		// create the light overlay
		lightOverlay = new Visual({
			name: 'light_overlay',
			texture: lightTexture,
			pos: new Vector(0, 0),
			size: new Vector(1024, 1024),
			shader: lightShader
		});

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
			depth: -1,
			batcher: lightBatcher
		});
		mainLight.updateEdgesFromSprites(walls);

		parcelLoaded = true;
	} // assetsLoaded

	override function onkeyup( e:KeyEvent ) {
		if(!parcelLoaded) { return; }

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
		if(!parcelLoaded) { return; }

		// get the mouse position
		mousePos = Luxe.camera.screen_point_to_world(e.pos);

		// update the whole shebang
		mainLight.centre = mousePos;
	}

	// use the pre-render function to render to render textures
	override function onprerender() {
		if(!parcelLoaded) { return; }

		// switch the render texture to the lights texture
		Luxe.renderer.target = lightTexture;

		// clear it
		Luxe.renderer.clear(new Color(0, 0, 0, 0));

		// draw all the lights using the batcher
		lightBatcher.draw();

		// unset the render target
		// so that we go back to rendering to the screen
		Luxe.renderer.target = null;
	}

	override function update(dt:Float) {
	} //update

} //Main
