//
//  Mesh.metal
//  Mandelbrot
//
//  Created by Nabil Birgle on 04/05/2024.
//
#include <metal_stdlib>
using namespace metal;

uint I(uint index, uint n){
	return index % n;
}

uint J(uint index, uint n){
	return index / n;
}

kernel
void vertices_function(constant uint& n [[buffer(0)]],
					   constant float2& v0 [[buffer(1)]],
					   constant float2& delta [[buffer(2)]],
					   device float2* v [[ buffer(3) ]],
					   uint index [[ thread_position_in_grid ]]){
	float2 z;
	if(index < (n+1)*(n+1)){
		uint i = I(index, n+1);
		uint j = J(index, n+1);
		float x = float(i) / float(n);
		float y = float(j) / float(n);
		z = {x, y};
	} else {
		uint i = I(index - (n+1)*(n+1), n);
		uint j = J(index - (n+1)*(n+1), n);
		float x = float(i + i+1) / float(2*n);
		float y = float(j + j+1) / float(2*n);
		z = {x, y};
	}
	v[index] = v0 + z * delta;
}

kernel
void triangles_function(constant uint& n [[buffer(0)]],
						  device uint32_t* t [[ buffer(1) ]],
						  uint index [[ thread_position_in_grid ]]){
	uint i = I(index / 12, n);
	uint j = J(index / 12, n);
	uint k = j*(n+1) + i;
	if((index % 12) < 3){
		if((index % 12) == 0){
			t[index] = k;
		} else if ((index % 12) == 1){
			t[index] = k+1;
		} else {
			t[index] = index/12 + (n+1)*(n+1);
		}
	} else if((index % 12) < 6){
		if((index % 12) == 3){
			t[index] = k+1;
		} else if ((index % 12) == 4){
			t[index] = k+n+2;
		} else {
			t[index] = index/12 + (n+1)*(n+1);
		}
	} else if((index % 12) < 9){
		if((index % 12) == 6){
			t[index] = k+n+2;
		} else if ((index % 12) == 7){
			t[index] = k+n+1;
		} else {
			t[index] = index/12 + (n+1)*(n+1);
		}
	} else {
		if((index % 12) == 9){
			t[index] = k+n+1;
		} else if ((index % 12) == 10){
			t[index] = k;
		} else {
			t[index] = index/12 + (n+1)*(n+1);
		}
	}
}

kernel
void zero_function(device float2* z [[ buffer(0) ]],
				   uint index [[ thread_position_in_grid ]]){
	z[index] = {0, 0};
}
