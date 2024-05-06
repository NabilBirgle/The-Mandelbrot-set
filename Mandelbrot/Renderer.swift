import MetalKit

class Renderer: NSObject {
	let gpu: GPU
	let command_queue: Command_queue
	var window: Window
	init(gpu: GPU,
		 command_queue: Command_queue,
		 metalView: MTKView,
		 window: Window,
		 update_function: String,
		 vertex_main: String,
		 fragment_main: String,
		 n_vertex_buffer: Int) {
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
		super.init()
	}
	func set_renderer(gpu: GPU,
					  metalView: MTKView,
					  update_function: String,
					  vertex_main: String,
					  fragment_main: String,
					  n_vertex_buffer: Int){
		gpu.set_compute_pipeline_state(function_name: update_function)
		gpu.set_render_pipeline_state(
			metalView: metalView,
			vertex_function: vertex_main,
			fragment_function: fragment_main,
			n_buffer: n_vertex_buffer
		)
	}
	var center: simd_float2 = [0, 0]
	func set_center(center: simd_float2){
		self.center = center
	}
	var radius: Float = 2
//	var scale: Float = 0.5 //* 0.9
	var delta_v: simd_float2 = [0, 0]
	func set_delta_v(delta_v: simd_float2){
		self.delta_v = delta_v
	}
	var frame: Int = 0
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
		if frame == 0 {
			update_window(command_buffer: command_buffer)
		}
		draw(view: view, command_buffer: command_buffer)
		frame = (frame + 1) % 60
		command_buffer.commit()
	}
	func draw(view: MTKView, command_buffer: Command_buffer){
		let render_command_encoder: Render_command_encoder
		= Render_command_encoder(view: view, command_buffer: command_buffer)
		render_command_encoder.set_input(x: &center)
		render_command_encoder.set_input(x: &radius)
		render_command_encoder.set_input(x: &delta_v)
		render_command_encoder.set_shader_input(
			window: window,
			render_pipeline_state: gpu.get_render_pipeline_state()
		)
		render_command_encoder.end()
	}
	func update_window(command_buffer: Command_buffer){
		let compute_command_encoder: Compute_command_encoder
		= Compute_command_encoder(command_buffer: command_buffer)
		compute_command_encoder.set_input(arr: window.mesh.vertex_buffer)
		compute_command_encoder.set_input(arr: window.mesh.z_n_buffer)
		compute_command_encoder.set_input(arr: window.mesh.color_buffer)
		compute_command_encoder.set_index_input(
			thread: window.mesh.n_v,
			compute_pipeline_state: gpu.get_compute_pipeline_state()
		)
		compute_command_encoder.end()
	}
}
