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
	func set_vertices(gpu: GPU,
					  command_buffer: Command_buffer,
					  center: (Float, Float),
					  radius: Float,
					  width: Float,
					  height: Float){
		let (x, y): (Float, Float) = center
		let w = radius * width / min(width,height)
		let h = radius * height / min(width, height)
		mesh.set_v0(x: x-w, y: y-h)
		mesh.set_delta_v(delta_x: 2*w, delta_y: 2*h)
		mesh.set_vertices(gpu: gpu, command_buffer: command_buffer)
	}
	func set_triangles(gpu: GPU, command_buffer: Command_buffer){
		mesh.set_triangles(gpu: gpu, command_buffer: command_buffer)
	}
	func set_z_n(gpu: GPU, command_buffer: Command_buffer){
		mesh.set_z_n(gpu: gpu, command_buffer: command_buffer)
	}
	func set_color(gpu: GPU, 
				   command_buffer: Command_buffer,
				   isWhite: inout Bool){
		mesh.set_color(gpu: gpu, 
					   command_buffer: command_buffer,
					   isWhite: &isWhite)
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
