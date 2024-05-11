import simd
import Metal

class Mesh {
	var n: UInt32
	var n_v: Int
	var n_t: Int
	var v0: simd_float2
	var delta_v: simd_float2
	var vertex_buffer: MTLBuffer
	var triangles_buffer: MTLBuffer
	var color_buffer: MTLBuffer
	var z_n_buffer: MTLBuffer
	init(n: UInt32, v0: simd_float2, delta_v: simd_float2, gpu: GPU){
		self.n = n
		self.n_v = Int((n+1)*(n+1) + n*n)
		self.n_t = Int(3*4*n*n)
		self.v0 = v0
		self.delta_v = delta_v
		guard
			let vertex_buffer = gpu.get_device()?.makeBuffer(
				length: MemoryLayout<simd_float2>.stride * self.n_v,
				options: .storageModeShared),
			let triangles_buffer = gpu.get_device()?.makeBuffer(
				length: MemoryLayout<UInt32>.stride * self.n_t,
				options: .storageModeShared),
			let color_buffer = gpu.get_device()?.makeBuffer(
				length: MemoryLayout<simd_float3>.stride * self.n_v,
				options: .storageModeShared),
			let z_n_buffer = gpu.get_device()?.makeBuffer(
				length: MemoryLayout<simd_float2>.stride * self.n_v,
				options: .storageModeShared)
		else {
			fatalError("Unable to create buffer")
		}
		self.vertex_buffer = vertex_buffer
		self.triangles_buffer = triangles_buffer
		self.color_buffer = color_buffer
		self.z_n_buffer = z_n_buffer
	}
	func set_vertices(command_buffer: Command_buffer,
					  vertices_function: String,
					  compute_pipeline_state: MTLComputePipelineState?){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(x: &n)
		compute_command_encoder.set_input(x: &v0)
		compute_command_encoder.set_input(x: &delta_v)
		compute_command_encoder.set_input(arr: vertex_buffer)
		compute_command_encoder.set_index_input(
			thread: n_v,
			compute_pipeline_state: compute_pipeline_state
		)
		compute_command_encoder.end()
	}
	func set_triangles(command_buffer: Command_buffer,
					   triangles_function: String,
					   compute_pipeline_state: MTLComputePipelineState?){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(x: &n)
		compute_command_encoder.set_input(arr: triangles_buffer)
		compute_command_encoder.set_index_input(
			thread: n_t,
			compute_pipeline_state: compute_pipeline_state
		)
		compute_command_encoder.end()
	}
	func set_z_n(command_buffer: Command_buffer,
				 zero_function: String,
				 compute_pipeline_state: MTLComputePipelineState?){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(arr: z_n_buffer)
		compute_command_encoder.set_index_input(
			thread: n_v,
			compute_pipeline_state: compute_pipeline_state
		)
		compute_command_encoder.end()
	}
	func set_color(command_buffer: Command_buffer,
				   isWhite: inout Bool,
				   zero_color_function: String,
				   compute_pipeline_state: MTLComputePipelineState?){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(x: &isWhite)
		compute_command_encoder.set_input(arr: color_buffer)
		compute_command_encoder.set_index_input(
			thread: n_v,
			compute_pipeline_state: compute_pipeline_state
		)
		compute_command_encoder.end()
	}
}
