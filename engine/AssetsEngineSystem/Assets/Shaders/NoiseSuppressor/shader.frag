#version 430 core
layout(location = 1) out vec4 OutColor;
in vec2 uv;


layout (binding = 0, rgba32f) uniform image2D MainTexture;
ivec2 size_texture = imageSize(MainTexture);
vec4 main_color = imageLoad(MainTexture, ivec2(gl_FragCoord.xy));

vec3 ver()
{
    ivec2 crd = ivec2(gl_FragCoord.xy);    
    ivec2 texsize = size_texture;
    vec4 c = imageLoad(MainTexture, crd);
    vec4 acc = c;
    float count = 1.0;
    float ra = c.a;
    int size = texsize.y/128;
    for (int yoff = -1; yoff > (-size-1); yoff--) {
        // Weight far away source pixels less
        float weight = 1.0-abs(float(yoff))/float(size);
        
		// Reflect at edge        
        ivec2 ycrd = crd+ivec2(0,yoff);
        //if (ycrd.y<0) ycrd = ivec2(crd.x, yoff-crd.y);
        
        vec4 oth = imageLoad(MainTexture, ycrd);
        float ddist = abs(oth.a-ra);
        if (ddist<0.5) {
            acc.rgb += oth.rgb*weight; 
            count += weight; 
            ra = oth.a; 
        }
    }
    ra = c.a;
    for (int yoff = 1; yoff < (size+1); yoff++) {
        // Weight far away source pixels less
        float weight = 1.0-abs(float(yoff))/float(size);
        
		// Reflect at edge        
        ivec2 ycrd = crd+ivec2(0,yoff);
        //if (ycrd.y>=texsize.y) ycrd = ivec2(crd.x, texsize.y-ycrd.y);
        
        vec4 oth = imageLoad(MainTexture, ycrd);
        float ddist = abs(oth.a-ra);
        if (ddist<0.5) {
            acc.rgb += oth.rgb*weight; 
            count += weight; 
            ra = oth.a;
        }
    }
    
    // Is this an edge that needs some anti-aliasing?
    if (count<=1.0) {
        acc.rgb += 0.25*imageLoad(MainTexture, crd+ivec2(0,-2)).rgb;
        acc.rgb += 0.5*imageLoad(MainTexture, crd+ivec2(0,-1)).rgb;
        acc.rgb += 0.5*imageLoad(MainTexture, crd+ivec2(0,1)).rgb;
        acc.rgb += 0.25*imageLoad(MainTexture, crd+ivec2(0,2)).rgb;
        count += 1.5;
    }

    return (acc * (1.0/count)).rgb;
}
vec3 hor()
{
    ivec2 crd = ivec2(gl_FragCoord.xy);    
    ivec2 texsize = size_texture;
    vec4 c = imageLoad(MainTexture, crd); 
    vec4 acc = c;
    float count = 1.0;
    float ra = c.a;
    int size = texsize.x/128;
    for (int xoff = -1; xoff > (-size-1); xoff--) {
        float weight = 1.0-abs(float(xoff))/float(size);
        ivec2 xcrd = crd+ivec2(xoff,0);
        vec4 oth = imageLoad(MainTexture, xcrd);
        float ddist = abs(oth.a-ra);
        if (ddist<0.5) { 
            acc.rgb += oth.rgb*weight; 
            count += weight; 
            ra = oth.a; 
        }
    }
    ra = c.a;
    for (int xoff = 1; xoff < (size+1); xoff++) {
        float weight = 1.0-abs(float(xoff))/float(size);
        ivec2 xcrd = crd+ivec2(xoff,0);
        vec4 oth = imageLoad(MainTexture, xcrd);
        float ddist = abs(oth.a-ra);
        if (ddist<0.5) {
            acc.rgb += oth.rgb*weight; 
            count += weight; 
            ra = oth.a;
        }
    }
    
    // Is this an edge that needs some anti-aliasing?
    if (count<=1.0) {
        acc.rgb += 0.25*imageLoad(MainTexture, crd+ivec2(-2,0)).rgb;
        acc.rgb += 0.5*imageLoad(MainTexture, crd+ivec2(-1,0)).rgb;
        acc.rgb += 0.5*imageLoad(MainTexture, crd+ivec2(1,0)).rgb;
        acc.rgb += 0.25*imageLoad(MainTexture, crd+ivec2(2,0)).rgb;
        count += 1.5;
    }
    
    return (acc * (1.0/count)).rgb;
}

uniform bool MOD;
uniform float DENOISING_STRENGTH;

// https://www.shadertoy.com/view/tt2SWK
// big thank you!

void main() {


	
    OutColor = vec4(
		mix(
			main_color.rgb,
			MOD?ver():hor(),
			DENOISING_STRENGTH
		)
	, main_color.a);
}