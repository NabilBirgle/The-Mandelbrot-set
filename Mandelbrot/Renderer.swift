import MetalKit

class Renderer: NSObject {
	let gpu: GPU
	let command_queue: Command_queue
	var mandelbrot: Window
	init(metalView: MTKView){
		self.gpu = GPU()
		gpu.set_device(metalView: metalView)
		gpu.set_library()

		let vertex_function = "vertex_main"
		let fragment_function = "fragment_main"
		let vertex_n_buffer: Int = 2
		gpu.compile(name: vertex_function)
		gpu.compile(name: fragment_function)
		gpu.set_render_pipeline_state(metalView: metalView,
									  vertex_function: vertex_function,
									  fragment_function: fragment_function,
									  n_buffer: vertex_n_buffer)

		gpu.compile(name: update_function)

		self.command_queue = Command_queue(gpu: gpu)
		self.mandelbrot = Window(device: gpu.device!)
		super.init()
		metalView.clearColor = MTLClearColor(
			red: 1.0,
			green: 1.0,
			blue: 0.8,
			alpha: 1.0)
		metalView.delegate = self
	}
	var timer: Float = 0
	var scale: Float = 0.5 * 0.9
	var delta_y: Float = 0
	var frame: Int = 0

	let update_function =  "update_function"
}

extension Renderer: MTKViewDelegate {
	func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize){
	}
	func draw(in view: MTKView){
		draw(view: view, command_queue: command_queue)
	}
	func draw(view: MTKView, command_queue: Command_queue){
		let command_buffer = Command_buffer(command_queue: command_queue)
		command_buffer.make_buffer(view: view)
		update_data()
		if frame == 0 {
			update_window(command_buffer: command_buffer)
		}
		draw(view: view, command_buffer: command_buffer)
		frame = (frame + 1) % 60
		command_buffer.commit()
	}
	func draw(view: MTKView, command_buffer: Command_buffer){
		let render_command_encoder: Render_command_encoder 
		= Render_command_encoder(command_buffer: command_buffer)
		render_command_encoder.call_vertex_function(
			view: view, render_pipeline_state: gpu.render_pipeline_state)
		render_command_encoder.set_input(x: &scale)
		render_command_encoder.set_input(x: &delta_y)
		render_command_encoder.set_input(window: mandelbrot)
		render_command_encoder.end()
	}
	func update_data(){
//		timer = Float(frame) * 2 * Float.pi / Float(60)
//		timer += 0.0005
		delta_y = 2*sin(timer)
	}
	func update_window(command_buffer: Command_buffer){
		let compute_command_encoder: Compute_command_encoder = Compute_command_encoder(command_buffer: command_buffer)
		gpu.set_compute_pipeline_state(function_name: "update_function")
		compute_command_encoder.call_kernel_function(compute_pipeline_state: gpu.compute_pipeline_state)
		compute_command_encoder.set_input(arr: mandelbrot.vertexBuffer)
		compute_command_encoder.set_input(arr: mandelbrot.z_nBuffer)
		compute_command_encoder.set_input(arr: mandelbrot.colorBuffer)
		compute_command_encoder.set_index_input(thread: mandelbrot.vertices.count, compute_pipeline_state: gpu.compute_pipeline_state)

		compute_command_encoder.end()
	}
}
