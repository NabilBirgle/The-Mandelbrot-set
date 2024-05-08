#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float2 position [[attribute(0)]];
  float3 color [[attribute(1)]];
};

struct VertexOut {
  float4 position [[position]];
  float4 color;
};

vertex
VertexOut vertex_main(constant float2& center [[buffer(0)]],
					  constant float& radius [[buffer(1)]],
					  constant float2& delta_v [[buffer(2)]],
					  constant float& magnify [[buffer(3)]],
					  constant float& width [[buffer(4)]],
					  constant float& height [[buffer(5)]],
					  VertexIn v [[stage_in]]){
	float2 p = (v.position + delta_v - center) / radius * magnify;
	float2 window = {width, height};
	float m = width < height ? width : height;
	p = p * m / window;
	float4 position = {p.x, p.y, 0.0, 1.0};
	float4 color = {v.color.x, v.color.y, v.color.z, 1.};
	VertexOut out { .position = position, .color = color };
	return out;
}

fragment 
float4 fragment_main(VertexOut v [[stage_in]]) {
  return v.color;
}
