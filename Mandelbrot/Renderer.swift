import MetalKit

class Renderer: NSObject {
	let gpu: GPU
	let command_queue: Command_queue
	let vertices_function = "vertices_function"
	let triangles_function = "triangles_function"
	let zero_function = "zero_function"
	let zero_color_function = "zero_color_function"
	let update_function =  "update_function"
	let vertex_main = "vertex_main"
	let fragment_main = "fragment_main"
	let n_vertex_buffer: Int = 6
	var window: Window
	var center: simd_float2
	var radius: Float
	init(gpu: GPU,
		 command_queue: Command_queue,
		 metalView: MTKView,
		 window: Window,
		 center: (Float, Float),
		 radius: Float) {
		gpu.compile(name: vertices_function)
		gpu.compile(name: triangles_function)
		gpu.compile(name: zero_function)
		gpu.compile(name: zero_color_function)
		gpu.compile(name: update_function)
		gpu.compile(name: vertex_main)
		gpu.compile(name: fragment_main)
		gpu.set_compute_pipeline_state(function_name: update_function)
		gpu.set_render_pipeline_state(
			metalView: metalView,
			vertex_function: vertex_main,
			fragment_function: fragment_main,
			n_buffer: n_vertex_buffer
		)
		self.gpu = gpu
		self.command_queue = command_queue
		self.window = window
		let (x, y) = center
		self.center = [x, y]
		self.radius = radius
		super.init()
	}
	func set_center(center: (Float, Float)){
		let (x, y) = center
		self.center = [x, y]
	}
	func set_radius(radius: Float){
		self.radius = radius
	}
	var delta_v: simd_float2 = [0, 0]
	func set_delta_v(delta_v: (Float, Float)){
		let (delta_x, delta_y) = delta_v
		self.delta_v = [delta_x, delta_y]
	}
	var isWhite: Bool = true
	func set_background(isWhite: Bool){
		self.isWhite = isWhite
	}
	var magnify: Float = 1
	func set_magnify(magnify: Float){
		self.magnify = magnify
	}
	var width: Float = 1
	var height: Float = 1
	func set_window(width: Float, height: Float){
		self.width = width
		self.height = height
	}
	enum Action: Equatable {
		case start(Int)
		case refresh(Int)
		case loading(Int)
	}
	var action_buffer: [Action] = [.start(0), .loading(0)]
	var isLoading: Bool = false
}

extension Renderer: MTKViewDelegate {
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize){
	}
	func draw(in view: MTKView){
		draw(view: view, command_queue: command_queue)
	}
	func draw(view: MTKView, command_queue: Command_queue){
		let command_buffer = Command_buffer(command_queue: command_queue)
		command_buffer.present(view: view)
		if isLoading {
			action_buffer.removeAll(where: {$0 == .loading(0)})
		}
		let action: Action? = action_buffer.popLast()
		action_buffer.removeAll(where: {$0 == action})
		var new_action: Action?
		switch action {
		case .start(let frame):
			new_action = start(frame: frame, command_buffer: command_buffer)
		case .loading(let frame):
			new_action = loading(frame: frame, command_buffer: command_buffer)
		case .refresh(let frame):
			new_action = refresh(frame: frame, command_buffer: command_buffer)
		default:
			update_window(command_buffer: command_buffer)
		}
		guard
			let a: Action = new_action
		else{
			draw(view: view, command_buffer: command_buffer)
			command_buffer.commit()
			return
		}
		action_buffer.append(a)
		draw(view: view, command_buffer: command_buffer)
		command_buffer.commit()
	}
	func loading(frame: Int, command_buffer: Command_buffer) -> Action? {
		switch frame {
		case 0:
			gpu.set_compute_pipeline_state(function_name: zero_color_function)
			window.mesh.set_color(
				command_buffer: command_buffer,
				isWhite: &isWhite,
				zero_color_function: zero_color_function,
				compute_pipeline_state: gpu.get_compute_pipeline_state()
			)
			isLoading = true
		default:
			return nil
		}
		return nil
	}
	func refresh(frame: Int, command_buffer: Command_buffer) -> Action? {
		switch frame {
		case 0:
			gpu.set_compute_pipeline_state(function_name: vertices_function)
			window.set_vertices(
				command_buffer: command_buffer,
				vertices_function: vertices_function,
				compute_pipeline_state: gpu.get_compute_pipeline_state(),
				center: (center[0], center[1]),
				radius: radius,
				width: width,
				height: height
			)
		case 1:
			gpu.set_compute_pipeline_state(function_name: zero_function)
			window.mesh.set_z_n(
				command_buffer: command_buffer,
				zero_function: zero_function,
				compute_pipeline_state: gpu.get_compute_pipeline_state()
			)
		case 2:
			gpu.set_compute_pipeline_state(function_name: update_function)
			update_window(command_buffer: command_buffer)
			isLoading = false
			return nil
		default:
			return .refresh(frame+1)
		}
		return .refresh(frame+1)
	}
	func start(frame: Int, command_buffer: Command_buffer) -> Action? {
		switch frame {
		case 0:
			gpu.set_compute_pipeline_state(function_name: vertices_function)
			window.set_vertices(
				command_buffer: command_buffer,
				vertices_function: vertices_function,
				compute_pipeline_state: gpu.get_compute_pipeline_state(),
				center: (center[0], center[1]),
				radius: radius,
				width: width,
				height: height
			)
		case 1:
			gpu.set_compute_pipeline_state(function_name: triangles_function)
			window.mesh.set_triangles(
				command_buffer: command_buffer,
				triangles_function: triangles_function,
				compute_pipeline_state: gpu.get_compute_pipeline_state()
			)
		case 2:
			gpu.set_compute_pipeline_state(function_name: zero_function)
			window.mesh.set_z_n(
				command_buffer: command_buffer,
				zero_function: zero_function,
				compute_pipeline_state: gpu.get_compute_pipeline_state()
			)
		case 3:
			gpu.set_compute_pipeline_state(function_name: update_function)
			update_window(command_buffer: command_buffer)
			isLoading = false
			return nil
		default:
			return .start(frame+1)
		}
		return .start(frame+1)
	}
	func update_window(command_buffer: Command_buffer){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(arr: window.mesh.vertex_buffer)
		compute_command_encoder.set_input(x: &isWhite)
		compute_command_encoder.set_input(arr: window.mesh.z_n_buffer)
		compute_command_encoder.set_input(arr: window.mesh.color_buffer)
		compute_command_encoder.set_index_input(
			thread: window.mesh.n_v,
			compute_pipeline_state: gpu.get_compute_pipeline_state()
		)
		compute_command_encoder.end()
	}
	func draw(view: MTKView, command_buffer: Command_buffer){
		let render_command_encoder: Render_command_encoder
		= Render_command_encoder(view: view, command_buffer: command_buffer)
		render_command_encoder.set_input(x: &center)
		render_command_encoder.set_input(x: &radius)
		render_command_encoder.set_input(x: &delta_v)
		render_command_encoder.set_input(x: &magnify)
		render_command_encoder.set_input(x: &width)
		render_command_encoder.set_input(x: &height)
		render_command_encoder.set_shader_input(
			window: window,
			render_pipeline_state: gpu.get_render_pipeline_state()
		)
		render_command_encoder.end()
	}
}
