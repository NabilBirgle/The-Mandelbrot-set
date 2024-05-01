#include <metal_stdlib>
using namespace metal;

//vertex
//float4 vertex_main(constant packed_float3* vertices [[buffer(0)]],
//				   constant ushort* indices [[buffer(1)]],
//				   constant simd_float3* color [[buffer(2)]],
//				   constant float& timer [[buffer(11)]],
//				   uint vertexID [[vertex_id]]){
//	ushort index = indices[vertexID];
//	float4 position = float4(vertices[index], 1);
//	position.y += timer;
//	return position;
//}

//vertex
//float4 vertex_main(float4 position [[attribute(0)]] [[stage_in]],
//				   constant float &timer [[buffer(11)]]){
//	return position;
//}
//
//fragment
//float4 fragment_main() {
//  return float4(0, 0, 1, 1);
//}



struct VertexIn {
  float4 position [[attribute(0)]];
  float4 color [[attribute(1)]];
};

struct VertexOut {
  float4 position [[position]];
  float4 color;
};

vertex
VertexOut vertex_main(constant float& scale [[buffer(0)]],
					  constant float& delta_y [[buffer(1)]],
					  VertexIn v [[stage_in]]){
	VertexOut out { .position = v.position, .color = v.color };
	out.position.y += delta_y;
	out.position.x *= scale;
	out.position.y *= scale;
	return out;
}

fragment 
float4 fragment_main(VertexOut v [[stage_in]]) {
  return v.color;
}




void mandelbrot_function(constant float2* z_n [[ buffer(0) ]],
				constant float2* c [[ buffer(1) ]],
				device float2* z [[ buffer(2) ]],
				uint index [[ thread_position_in_grid ]]){
	float x = z_n[index].x;
	float y = z_n[index].y;
	z[index].x = c[index].x + x*x - y*y;
	z[index].y = c[index].y + 2*x*y;
}

void module_function(constant float2* z [[ buffer(0) ]],
					 device float* module [[ buffer(1) ]],
					 uint index [[ thread_position_in_grid ]]){
	float x = z[index].x;
	float y = z[index].y;
	module[index] = sqrt(x*x + y*y);
}

void color_function(constant float* module [[ buffer(0) ]],
					 device float3* color [[ buffer(1) ]],
					 uint index [[ thread_position_in_grid ]]){
//	color[index].x = 1.0 * module[index];
//	color[index].y = 1.0 * module[index];
//	color[index].z = 0.8 * module[index];

	float pi = 4 * atan(1.);
	float i = 2 * atan(module[index]) / pi;
	color[index].x = 1.0 * i;
	color[index].y = 1.0 * i;
	color[index].z = 0.8 * i;

//	color[index].x = (module[index] > 1) ? 1.0 : 0;
//	color[index].y = (module[index] > 1) ? 1.0 : 0;
//	color[index].z = (module[index] > 1) ? 0.8 : 0;
}

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

kernel
void update_function(constant float2* v [[ buffer(0) ]],
					 device float2* z_n [[ buffer(1) ]],
					 device float3* color [[ buffer(2) ]],
					 uint index [[ thread_position_in_grid ]]){
	float module = module_function(z_n[index]);
	if(module < 2){
		z_n[index] = mandelbrot_function(z_n[index], v[index]);
		float module = module_function(z_n[index]);
		float pi = 4 * atan(1.);
		float i = 2 * atan(module) / pi;
		color[index].x = module < 2 ? 0 : 1.0 * i;
		color[index].y = module < 2 ? 0 : 1.0 * i;
		color[index].z = module < 2 ? 0 : 0.8 * i;
	}
}
