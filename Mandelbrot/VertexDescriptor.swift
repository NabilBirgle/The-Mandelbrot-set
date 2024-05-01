import MetalKit

extension MTLVertexDescriptor {
	static func defaultLayout(n_buffer: Int) -> MTLVertexDescriptor {
		let vertexDescriptor = MTLVertexDescriptor()
		var n: Int = n_buffer
		vertexDescriptor.attributes[0].format = .float2
		vertexDescriptor.attributes[0].offset = 0
		vertexDescriptor.attributes[0].bufferIndex = n
		vertexDescriptor.layouts[n].stride = MemoryLayout<simd_float2>.stride

		n += 1
		vertexDescriptor.attributes[1].format = .float3
		vertexDescriptor.attributes[1].offset = 0
		vertexDescriptor.attributes[1].bufferIndex = n
		vertexDescriptor.layouts[n].stride = MemoryLayout<simd_float3>.stride

		return vertexDescriptor
	}
}
