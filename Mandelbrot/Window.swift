import MetalKit

func pow(_ x: Int, _ y: Int) -> Int {
	y == 0 ? 1 : pow(x, y-1)*x
}

struct Window {
	let mesh: Mesh
	init(gpu: GPU, 
		 center: (Float, Float),
		 radius: Float,
		 width: Float,
		 height: Float){
		let (x, y): (Float, Float) = center
		let w = radius * width / min(width,height)
		let h = radius * height / min(width, height)
		let mesh: Mesh = Mesh(n: UInt32(pow(2, 10)),
							  v0: [x-w, y-h],
							  delta_v: 2*[w, h],
							  gpu: gpu)
		self.mesh = mesh
	}
	func set_vertices(command_buffer: Command_buffer,
					  vertices_function: String,
					  compute_pipeline_state: MTLComputePipelineState?,
					  center: (Float, Float),
					  radius: Float,
					  width: Float,
					  height: Float){
		let (x, y): (Float, Float) = center
		let w = radius * width / min(width,height)
		let h = radius * height / min(width, height)
		mesh.v0 = [x-w, y-h]
		mesh.delta_v = 2*[w, h]
		mesh.set_vertices(command_buffer: command_buffer,
						  vertices_function: vertices_function, 
						  compute_pipeline_state: compute_pipeline_state)
	}
}
