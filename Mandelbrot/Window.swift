import MetalKit

struct Window {
	private let mesh: Mesh
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
					  gpu: GPU,
					  center: (Float, Float),
					  radius: Float,
					  width: Float,
					  height: Float){
		let (x, y): (Float, Float) = center
		let w = radius * width / min(width,height)
		let h = radius * height / min(width, height)
		mesh.set_v0(x: x-w, y: y-h)
		mesh.set_delta_v(delta_x: 2*w, delta_y: 2*h)
		mesh.set_vertices(command_buffer: command_buffer,
						  gpu: gpu)
	}
	func set_triangles(command_buffer: Command_buffer,
					   gpu: GPU){
		mesh.set_triangles(command_buffer: command_buffer,
						   gpu: gpu)
	}
	func set_z_n(command_buffer: Command_buffer,
				 gpu: GPU){
		mesh.set_z_n(command_buffer: command_buffer,
					 gpu: gpu)
	}
	func set_color(command_buffer: Command_buffer,
				   isWhite: inout Bool,
				   gpu: GPU){
		mesh.set_color(command_buffer: command_buffer,
					   isWhite: &isWhite,
					   gpu: gpu)
	}
	func get_n_v() -> Int {
		mesh.get_n_v()
	}
	func get_n_t() -> Int {
		mesh.get_n_t()
	}
	func get_vertices() -> MTLBuffer {
		mesh.get_vertices()
	}
	func get_triangles() -> MTLBuffer {
		mesh.get_triangles()
	}
	func get_z_n() -> MTLBuffer {
		mesh.get_z_n()
	}
	func get_color() -> MTLBuffer {
		mesh.get_color()
	}

}
