import MetalKit

class Renderer: NSObject {
	let gpu: GPU
	let command_queue: Command_queue
	var mandelbrot: Window?

	let vertex_function = "vertex_main"
	let fragment_function = "fragment_main"
	let vertex_n_buffer: Int = 1
	let update_function =  "update_function"
	init(metalView: MTKView){
		self.gpu = GPU()
		gpu.set_device(metalView: metalView)
		gpu.set_library()
		gpu.compile(name: vertex_function)
		gpu.compile(name: fragment_function)
		gpu.set_render_pipeline_state(metalView: metalView,
									  vertex_function: vertex_function,
									  fragment_function: fragment_function,
									  n_buffer: vertex_n_buffer)
		gpu.compile(name: update_function)
		self.command_queue = Command_queue(gpu: gpu)
		guard
			let device: MTLDevice = gpu.device
		else {
			self.mandelbrot = nil
			super.init()
			return
		}
		self.mandelbrot = Window(device: device)
		super.init()
		metalView.clearColor = MTLClearColor(
			red: 1.0,
			green: 1.0,
			blue: 0.8,
			alpha: 1.0)
		metalView.delegate = self
	}
	var scale: Float = 0.5 * 0.9
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
		guard
			let mandelbrot: Window = mandelbrot
		else {
			return
		}
		let render_command_encoder: Render_command_encoder
		= Render_command_encoder(view: view, command_buffer: command_buffer)
		render_command_encoder.set_input(x: &scale)
		render_command_encoder.set_shader_input(window: mandelbrot, render_pipeline_state: gpu.get_render_pipeline_state())
		render_command_encoder.end()
	}
	func update_window(command_buffer: Command_buffer){
		guard
			let mandelbrot: Window = mandelbrot
		else {
			return
		}
		let compute_command_encoder: Compute_command_encoder = Compute_command_encoder(command_buffer: command_buffer)
		gpu.set_compute_pipeline_state(function_name: update_function)
		compute_command_encoder.set_input(arr: mandelbrot.vertexBuffer)
		compute_command_encoder.set_input(arr: mandelbrot.z_nBuffer)
		compute_command_encoder.set_input(arr: mandelbrot.colorBuffer)
		compute_command_encoder.set_index_input(thread: mandelbrot.vertices.count, compute_pipeline_state: gpu.get_compute_pipeline_state())
		compute_command_encoder.end()
	}
}
