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
					  VertexIn v [[stage_in]]){
	float4 position = {v.position.x, v.position.y, 0., 1.};
	float4 color = {v.color.x, v.color.y, v.color.z, 1.};
	position.x = (v.position.x + delta_v.x - center.x) / radius * magnify;
	position.y = (v.position.y + delta_v.y - center.y) / radius * magnify;
	VertexOut out { .position = position, .color = color };
	return out;
}

fragment 
float4 fragment_main(VertexOut v [[stage_in]]) {
  return v.color;
}
