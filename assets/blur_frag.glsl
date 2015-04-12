uniform sampler2D tex0;
varying vec4 color;
varying vec2 blurTexCoords[25];

void main() {
	vec4 tempColour = vec4(0.0);

	tempColour += color * texture2D(tex0, blurTexCoords[ 0]) * 0.0073068827452812644; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 1]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 2]) * 0.05399096651318985; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 3]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 4]) * 0.0073068827452812644; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 5]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 6]) * 0.14676266317374237; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 7]) * 0.24197072451914536; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 8]) * 0.14676266317374237; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[ 9]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[10]) * 0.05399096651318985; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[11]) * 0.24197072451914536; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[12]) * 0.3989422804014327; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[13]) * 0.24197072451914536; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[14]) * 0.05399096651318985; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[15]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[16]) * 0.14676266317374237; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[17]) * 0.24197072451914536; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[18]) * 0.14676266317374237; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[19]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[20]) * 0.0073068827452812644; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[21]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[22]) * 0.05399096651318985; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[23]) * 0.03274717653776802; // 0.04
	tempColour += color * texture2D(tex0, blurTexCoords[24]) * 0.0073068827452812644; // 0.04

	gl_FragColor = tempColour;
}
