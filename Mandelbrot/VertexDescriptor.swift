import MetalKit

extension MTLVertexDescriptor {
	static func defaultLayout(n_buffer: Int) -> MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		var a: Int = 0
		var n: Int = n_buffer
		vertexDescriptor.attributes[a].format = .float2
		vertexDescriptor.attributes[a].offset = 0
		vertexDescriptor.attributes[a].bufferIndex = n
		vertexDescriptor.layouts[n].stride = MemoryLayout<simd_float2>.stride
		a += 1
		n += 1
		vertexDescriptor.attributes[a].format = .float3
		vertexDescriptor.attributes[a].offset = 0
		vertexDescriptor.attributes[a].bufferIndex = n
		vertexDescriptor.layouts[n].stride = MemoryLayout<simd_float3>.stride
		return vertexDescriptor
	}
}
