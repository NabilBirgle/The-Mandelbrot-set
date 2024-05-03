import MetalKit

struct Window {
	var vertices: [simd_float2]
	var triangles: [UInt32]
	var colors: [simd_float3]
	var z_n: [simd_float2]

	var vertexBuffer: MTLBuffer
	var trianglesBuffer: MTLBuffer
	var colorBuffer: MTLBuffer
	var z_nBuffer: MTLBuffer

	init(device: MTLDevice){
		let mesh: Mesh = Mesh(n: 512)
		let a: simd_float2 = [-2, -2]
		let b: simd_float2 = [2, 2]
		self.vertices = mesh.vertices.map({ $0 * (b-a) + a })
		self.triangles = mesh.triangles
		self.colors = [simd_float3].init(repeating: [0, 0, 0], count: vertices.count)
		self.z_n = [simd_float2].init(repeating: [0, 0], count: vertices.count)
		guard
			let vertexBuffer = device.makeBuffer(
				bytes: &vertices,
				length: MemoryLayout<simd_float2>.stride * vertices.count,
				options: .storageModeShared),
			let trianglesBuffer = device.makeBuffer(
				bytes: &triangles,
				length: MemoryLayout<UInt32>.stride * triangles.count,
				options: .storageModeShared),
			let colorBuffer = device.makeBuffer(
				bytes: &colors,
				length: MemoryLayout<simd_float3>.stride * colors.count,
				options: .storageModeShared),
			let z_nBuffer = device.makeBuffer(
				bytes: &z_n,
				length: MemoryLayout<simd_float2>.stride * vertices.count,
				options: .storageModeShared)
		else {
			fatalError("Unable to create buffer")
		}
		self.vertexBuffer = vertexBuffer
		self.trianglesBuffer = trianglesBuffer
		self.colorBuffer = colorBuffer
		self.z_nBuffer = z_nBuffer
	}
}
