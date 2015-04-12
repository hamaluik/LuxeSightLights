package options;

import luxe.Color;
import luxe.Vector;
import phoenix.Shader;
import luxe.options.EntityOptions;
import luxe.options.RenderProperties;

typedef SightLineOptions = {
	> RenderProperties,
	> EntityOptions,

	@:optional var shader:Shader;
	@:optional var colour:Color;
	@:optional var visible:Bool;
	@:optional var centre:Vector;
} // SightLineOptions