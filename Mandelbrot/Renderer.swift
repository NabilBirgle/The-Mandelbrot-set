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
	var width: Float
	var height: Float
	init(gpu: GPU,
		 command_queue: Command_queue,
		 metalView: MTKView,
		 window: Window,
		 center: (Float, Float),
		 radius: Float,
		 width: Float,
		 height: Float) {
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
		self.width = width
		self.height = height
		super.init()
	}
	var delta_v: simd_float2 = [0, 0]
	var isWhite: Bool = true
	func set_background(isWhite: Bool){
		self.isWhite = isWhite
	}
	var magnify: Float = 1
	var action_buffer: [Action] = [.loading(0), .start(0), .update_color(0)]
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
//		let n: Int = action_buffer.count
		let action: Action? = action_buffer.max(by: <=)
		action_buffer.removeAll(where: {($0 == action)})
		var new_action: Action?
		switch action {
		case .start(let frame):
			new_action = start(frame: frame, command_buffer: command_buffer)
		case .loading(let frame):
			new_action = loading(frame: frame, command_buffer: command_buffer)
		case .refresh(let frame):
			new_action = refresh(frame: frame, command_buffer: command_buffer)
		case .set_window(let width, let height):
			self.width = width
			self.height = height
		case .set_radius(let radius):
			self.radius = radius
		case .set_center(let x, let y):
			self.center = [x, y]
		case .set_delta_v(let delta_x, let delta_y):
			self.delta_v = [delta_x, delta_y]
		case .set_magnify(let magnifyBy):
			self.magnify = magnifyBy
		case .update_color(let frame):
			new_action = update_color(frame: frame, command_buffer: command_buffer)
		default:
			if !isLoading {
				update_window(command_buffer: command_buffer)
			}
		}
		guard
			let a: Action = new_action
		else{
			draw(view: view, command_buffer: command_buffer)
			command_buffer.commit()
			return
		}
		action_buffer.insert(a, at: 0)
		draw(view: view, command_buffer: command_buffer)
		command_buffer.commit()
	}
	func start(frame: Int, command_buffer: Command_buffer) -> Action? {
		switch frame {
		case 0:
			gpu.set_compute_pipeline_state(function_name: vertices_function)
			window.set_vertices(
				command_buffer: command_buffer,
				vertices_function: vertices_function,
				gpu: gpu,
				center: (center[0], center[1]),
				radius: radius,
				width: width,
				height: height
			)
		case 1:
			gpu.set_compute_pipeline_state(function_name: triangles_function)
			window.set_triangles(
				command_buffer: command_buffer,
				triangles_function: triangles_function,
				gpu: gpu
			)
		case 2:
			gpu.set_compute_pipeline_state(function_name: zero_function)
			window.set_z_n(
				command_buffer: command_buffer,
				zero_function: zero_function,
				gpu: gpu
			)
			return nil
		default:
			return .start(frame+1)
		}
		return .start(frame+1)
	}
	func loading(frame: Int, command_buffer: Command_buffer) -> Action? {
		switch frame {
		case 0:
			gpu.set_compute_pipeline_state(function_name: zero_color_function)
			window.set_color(
				command_buffer: command_buffer,
				isWhite: &isWhite,
				zero_color_function: zero_color_function,
				gpu: gpu
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
				gpu: gpu,
				center: (center[0], center[1]),
				radius: radius,
				width: width,
				height: height
			)
		case 1:
			gpu.set_compute_pipeline_state(function_name: zero_function)
			window.set_z_n(
				command_buffer: command_buffer,
				zero_function: zero_function,
				gpu: gpu
			)
			return nil
		default:
			return .refresh(frame+1)
		}
		return .refresh(frame+1)
	}
	func update_color(frame: Int, command_buffer: Command_buffer) -> Action? {
		switch frame {
		case 0:
			gpu.set_compute_pipeline_state(function_name: update_function)
			update_window(command_buffer: command_buffer)
			isLoading = false
		default:
			return nil
		}
		return nil
	}
	func update_window(command_buffer: Command_buffer){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(arr: window.get_vertices())
		compute_command_encoder.set_input(x: &isWhite)
		compute_command_encoder.set_input(arr: window.get_z_n())
		compute_command_encoder.set_input(arr: window.get_color())
		compute_command_encoder.set_index_input(
			thread: window.get_n_v(),
			gpu: gpu
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
			gpu: gpu
		)
		render_command_encoder.end()
	}
}
