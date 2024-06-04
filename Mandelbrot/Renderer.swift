import MetalKit

class Renderer: NSObject {
	private let gpu: GPU
	private let command_queue: Command_queue
	private let vertices_function = "vertices_function"
	private let triangles_function = "triangles_function"
	private let zero_function = "zero_function"
	private let zero_color_function = "zero_color_function"
	private let update_function =  "update_function"
	private let vertex_main = "vertex_main"
	private let fragment_main = "fragment_main"
	/// n_vertex_buffer doit être modifier en fonction du nombre de paramètre de la fonction vertex dans Shaders.metal. Si sa valeur est incorrect, le Preview bug et il est possible que Xcode plante  jusqu'à forcer la session à se verrouiller. (Xcode Version 15.4, 2024)
	private let n_vertex_buffer: Int = 6
	private var window: Window
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
		self.CPU_parameters = windows_parameters(center: [x, y], radius: radius, width: width, height: height)
		self.GPU_parameters = windows_parameters(center: [x, y], radius: radius, width: width, height: height)
		super.init()
	}
	private var action_buffer: [Action] = [.loading(0), .start(0), .update_color(0)]
	func add_setting(actions: [Action]){
		action_buffer.append(contentsOf: actions)
	}	
	func add_setting(action: Action){
		action_buffer.append(action)
	}
	private var isLoading: Bool = false
	var CPU_parameters: windows_parameters
	var GPU_parameters: windows_parameters
	class windows_parameters {
		var center: simd_float2
		var radius: Float
		var width: Float
		var height: Float
		init(center: simd_float2, radius: Float, width: Float, height: Float) {
			self.center = center
			self.radius = radius
			self.width = width
			self.height = height
		}
		var delta_v: simd_float2 = [0, 0]
		var isWhite: Bool = true
		var magnify: Float = 1
	}
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
		let action: Action? = action_buffer.max(by: <)
		action_buffer.removeAll(where: {($0 == action)})
		var new_action: Action?
		switch action {
		case .start(let frame):
			new_action = start(frame: frame, command_buffer: command_buffer)
		case .loading(let frame):
			new_action = loading(frame: frame, command_buffer: command_buffer)
		case .refresh(let frame):
			new_action = refresh(frame: frame, command_buffer: command_buffer)
		case .set_window(let frame):
			GPU_parameters = CPU_parameters
		case .set_radius(let frame):
			GPU_parameters = CPU_parameters
		case .set_center(let frame):
			GPU_parameters = CPU_parameters
		case .set_delta_v(let frame):
			GPU_parameters = CPU_parameters
		case .set_magnify(let frame):
			GPU_parameters = CPU_parameters
		case .set_background(let frame):
			GPU_parameters = CPU_parameters
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
		gpu.set_compute_pipeline_state(function_name: vertices_function)
		window.set_vertices(
			gpu: gpu,
			command_buffer: command_buffer,
			center: (GPU_parameters.center[0], GPU_parameters.center[1]),
			radius: GPU_parameters.radius,
			width: GPU_parameters.width,
			height: GPU_parameters.height
		)
		gpu.set_compute_pipeline_state(function_name: triangles_function)
		window.set_triangles(gpu: gpu, command_buffer: command_buffer)
		gpu.set_compute_pipeline_state(function_name: zero_function)
		window.set_z_n(gpu: gpu, command_buffer: command_buffer)
		return nil
	}
	func loading(frame: Int, command_buffer: Command_buffer) -> Action? {
		gpu.set_compute_pipeline_state(function_name: zero_color_function)
		window.set_color(gpu: gpu,
						 command_buffer: command_buffer,
						 isWhite: &GPU_parameters.isWhite
		)
		isLoading = true
		return nil
	}
	func refresh(frame: Int, command_buffer: Command_buffer) -> Action? {
		gpu.set_compute_pipeline_state(function_name: vertices_function)
		window.set_vertices(gpu: gpu,
							command_buffer: command_buffer,
							center: (GPU_parameters.center[0], GPU_parameters.center[1]),
							radius: GPU_parameters.radius,
							width: GPU_parameters.width,
							height: GPU_parameters.height
		)
		gpu.set_compute_pipeline_state(function_name: zero_function)
		window.set_z_n(gpu: gpu, command_buffer: command_buffer)
		return nil
	}
	func update_color(frame: Int, command_buffer: Command_buffer) -> Action? {
		gpu.set_compute_pipeline_state(function_name: update_function)
		update_window(command_buffer: command_buffer)
		isLoading = false
		return nil
	}
	func update_window(command_buffer: Command_buffer){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(arr: window.get_vertices())
		compute_command_encoder.set_input(x: &GPU_parameters.isWhite)
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
		render_command_encoder.set_input(x: &GPU_parameters.center)
		render_command_encoder.set_input(x: &GPU_parameters.radius)
		render_command_encoder.set_input(x: &GPU_parameters.delta_v)
		render_command_encoder.set_input(x: &GPU_parameters.magnify)
		render_command_encoder.set_input(x: &GPU_parameters.width)
		render_command_encoder.set_input(x: &GPU_parameters.height)
		render_command_encoder.set_shader_input(
			window: window,
			gpu: gpu
		)
		render_command_encoder.end()
	}
}
