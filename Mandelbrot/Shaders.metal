#include <metal_stdlib>
using namespace metal;

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
