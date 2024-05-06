//
//  Kernel.metal
//  Mandelbrot
//
//  Created by Nabil Birgle on 01/05/2024.
//

#include <metal_stdlib>
using namespace metal;

float module_function(float2 z){
	float x = z.x;
	float y = z.y;
	return sqrt(x*x + y*y);
}

float2 mandelbrot_function(float2 z, float2 v){
	float x = v.x + z.x*z.x - z.y*z.y;
	float y = v.y + 2*z.x*z.y;
	return {x, y};
}

float3 color_function(float m, float3 c){
	float pi = 4 * atan(1.);
	float i = 2 * atan(m) / pi;
	float red = m <= 2 ? 0 : c.x * i;
	float green = m <= 2 ? 0 : c.y * i;
	float blue = m <= 2 ? 0 : c.z * i;
	return {red, green, blue};
}
//
//float3 cream_color(){
//	return {1.0, 1.0, 0.8};
//}

float3 cream_color(){
	return {1.0, 1.0, 0.8};
}

kernel
void update_function(constant float2* v [[ buffer(0) ]],
					 device float2* z_n [[ buffer(1) ]],
					 device float3* color [[ buffer(2) ]],
					 uint index [[ thread_position_in_grid ]]){
	float module = module_function(z_n[index]);
	if(module <= 2){
		z_n[index] = mandelbrot_function(z_n[index], v[index]);
		float module = module_function(z_n[index]);
		float3 c = cream_color();
		color[index] = color_function(module, c);
	}
}
