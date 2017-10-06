#include "/settings.glsl"

const bool colortex2MipmapEnabled = true;
//----------------------------------------------------------------------------//

// Viewport
uniform float viewWidth, viewHeight;
uniform float aspectRatio;

// Samplers
uniform sampler2D colortex2;

//----------------------------------------------------------------------------//

varying vec2 screenCoord;

//----------------------------------------------------------------------------//

#include "/lib/util/clamping.glsl"
#include "/lib/util/math.glsl"

vec3 generateGlareTileHor(vec2 coord, const float lod) {
	if (floor(coord) != vec2(0.0)) return vec3(0.0);

	const float[5] weights = float[5](0.19947114, 0.29701803, 0.09175428, 0.01098007, 0.00050326);
	const float[5] offsets = float[5](0.00000000, 1.40733340, 3.29421497, 5.20181322, 7.13296424);

	vec2 resolution = textureSize2D(colortex2, int(lod));

	vec3 tile = texture2DLod(colortex2, coord, lod).rgb * weights[0];
	for (int i = 1; i < 5; i++) {
		vec2 offset = offsets[i] * vec2(1.0 / resolution.x, 0.0);
		tile += texture2DLod(colortex2, coord + offset, lod).rgb * weights[i];
		tile += texture2DLod(colortex2, coord - offset, lod).rgb * weights[i];
	}
	return tile;
}

void main() {
	#ifdef GLARE
	vec2 px = 1.0 / vec2(viewWidth, viewHeight);

	vec3
	glare  = generateGlareTileHor(screenCoord * exp2(1), 1);
	glare += generateGlareTileHor((screenCoord - (vec2(0, 8) * px + vec2(0.0000, 0.50000))) * exp2(2), 2);
	glare += generateGlareTileHor((screenCoord - (vec2(2, 8) * px + vec2(0.2500, 0.50000))) * exp2(3), 3);
	glare += generateGlareTileHor((screenCoord - (vec2(2,16) * px + vec2(0.2500, 0.62500))) * exp2(4), 4);
	glare += generateGlareTileHor((screenCoord - (vec2(4,16) * px + vec2(0.3125, 0.62500))) * exp2(5), 5);
	glare += generateGlareTileHor((screenCoord - (vec2(4,24) * px + vec2(0.3125, 0.65625))) * exp2(6), 6);

/* DRAWBUFFERS:3 */

	gl_FragData[0] = vec4(glare, 1.0);
	#else
	discard;
	#endif
}
