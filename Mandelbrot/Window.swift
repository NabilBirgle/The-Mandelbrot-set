import MetalKit

func pow(_ x: Int, _ y: Int) -> Int {
	y == 0 ? 1 : pow(x, y-1)*x
}


struct Window {
	let mesh: Mesh
	init(gpu: GPU,
		 command_queue: Command_queue,
		 center: (Float, Float),
		 radius: Float,
		 vertices_function: String,
		 triangles_function: String,
		 zero_function: String){
		let (x, y): (Float, Float) = center
		let mesh: Mesh = Mesh(n: UInt32(pow(2, 10)),
							  v0: [x-radius, y-radius],
							  delta_v: 2 * radius,
							  gpu: gpu)
		mesh.set_mesh(gpu: gpu,
					  command_queue: command_queue,
					  vertices_function: vertices_function,
					  triangles_function: triangles_function,
					  zero_function: zero_function)
		self.mesh = mesh
	}
	func set_vertices(gpu: GPU,
					  command_queue: Command_queue,
					  vertices_function: String,
					  center: (Float, Float), 
					  radius: Float){
		let (x, y): (Float, Float) = center
		mesh.v0 = [x-radius, y-radius]
		mesh.delta_v = 2 * radius
		mesh.set_vertices(gpu: gpu,
						  command_queue: command_queue,
						  vertices_function: vertices_function)
	}
}
