import MetalKit

class GPU {
	private var device: MTLDevice?
	private var library: MTLLibrary?
	init(){
		self.device = MTLCreateSystemDefaultDevice()
		self.library = device?.makeDefaultLibrary()
	}
	func get_device() -> MTLDevice? {
		device
	}
	private var functions: [String: MTLFunction] = [:]
	func compile(name: String){
		functions[name] = library?.makeFunction(name: name)
	}
	private var render_pipeline_state: MTLRenderPipelineState?
	func set_render_pipeline_state(metalView: MTKView,
								   vertex_function: String,
								   fragment_function: String,
								   n_buffer: Int){
		let pipelineDescriptor: MTLRenderPipelineDescriptor = MTLRenderPipelineDescriptor()
		pipelineDescriptor.vertexFunction = functions[vertex_function]
		pipelineDescriptor.fragmentFunction = functions[fragment_function]
		pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
		pipelineDescriptor.vertexDescriptor =
		MTLVertexDescriptor.defaultLayout(n_buffer: n_buffer)
		do {
			render_pipeline_state =
			try device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
	func get_render_pipeline_state() -> MTLRenderPipelineState? {
		render_pipeline_state
	}
	private var compute_pipeline_state: MTLComputePipelineState?
	func set_compute_pipeline_state(function_name: String){
		guard
			let f: MTLFunction = functions[function_name]
		else {
			compute_pipeline_state = nil
			return
		}
		do {
			compute_pipeline_state = try device?.makeComputePipelineState(function: f)
		} catch {
			print(error)
		}
	}
	func get_compute_pipeline_state() -> MTLComputePipelineState? {
		compute_pipeline_state
	}
}

class Command_queue {
	private var command_queue: MTLCommandQueue?
	init(gpu: GPU) {
		command_queue = gpu.get_device()?.makeCommandQueue()
	}
	func make_command_buffer() -> MTLCommandBuffer? {
		command_queue?.makeCommandBuffer()
	}
}

class Command_buffer {
	private var command_buffer: MTLCommandBuffer?
	init(command_queue: Command_queue){
		self.command_buffer = command_queue.make_command_buffer()
	}
	func present(view: MTKView){
		guard
			let drawable = view.currentDrawable
		else {
			command_buffer = nil
			return
		}
		command_buffer?.present(drawable)
	}
	func make_render_command_encoder(descriptor: MTLRenderPassDescriptor) -> MTLRenderCommandEncoder? {
		command_buffer?.makeRenderCommandEncoder(descriptor: descriptor)
	}
	func make_compute_command_encoder() -> MTLComputeCommandEncoder? {
		command_buffer?.makeComputeCommandEncoder()
	}
	func commit(){
		command_buffer?.commit()
	}
}

class Render_command_encoder{
	private var command_encoder: MTLRenderCommandEncoder?
	init(view: MTKView, command_buffer: Command_buffer) {
		guard
			let descriptor: MTLRenderPassDescriptor = view.currentRenderPassDescriptor
		else {
			command_encoder = nil
			return
		}
		command_encoder = command_buffer.make_render_command_encoder(
			descriptor: descriptor
		)
	}
	var input: Int = 0
	func set_input(x: inout Float){
		command_encoder?.setVertexBytes(
			&x, length: MemoryLayout<Float>.stride, index: input
		)
		input += 1
	}
	func set_input(x: inout simd_float2){
		command_encoder?.setVertexBytes(
			&x, length: MemoryLayout<simd_float2>.stride, index: input
		)
		input += 1
	}
	func set_input(arr: MTLBuffer){
		command_encoder?.setVertexBuffer(arr, offset: 0, index: input)
		input += 1
	}
	func set_shader_input(window: Window, 
						  render_pipeline_state: MTLRenderPipelineState?){
		set_input(arr: window.mesh.vertex_buffer)
		set_input(arr: window.mesh.color_buffer)
		guard
			let pipeline_state: MTLRenderPipelineState = render_pipeline_state
		else {
			command_encoder = nil
			return
		}
		command_encoder?.setRenderPipelineState(pipeline_state)
		command_encoder?.drawIndexedPrimitives(
			type: .triangle,
			indexCount: window.mesh.n_t,
			indexType: .uint32,
			indexBuffer: window.mesh.triangles_buffer,
			indexBufferOffset: 0)
	}
	func end(){
		command_encoder?.endEncoding()
	}
}

class Compute_command_encoder{
	private var command_encoder: MTLComputeCommandEncoder?
	init(command_buffer: Command_buffer){
		command_encoder = command_buffer.make_compute_command_encoder()
	}
	var input: Int = 0
	func set_input(x: inout Bool){
		command_encoder?.setBytes(&x,
								  length: MemoryLayout<Bool>.stride,
								  index: input)
		input += 1
	}
	func set_input(x: inout UInt32){
		command_encoder?.setBytes(&x,
								  length: MemoryLayout<UInt32>.stride,
								  index: input)
		input += 1
	}
	func set_input(x: inout Float){
		command_encoder?.setBytes(&x,
								  length: MemoryLayout<Float>.stride,
								  index: input)
		input += 1
	}
	func set_input(x: inout simd_float2){
		command_encoder?.setBytes(&x,
								  length: MemoryLayout<simd_float2>.stride,
								  index: input)
		input += 1
	}
	func set_input(arr: MTLBuffer){
		command_encoder?.setBuffer(arr, offset: 0, index: input)
		input += 1
	}
	func set_index_input(thread: Int, compute_pipeline_state: MTLComputePipelineState?){
		guard
			let pipeline_state: MTLComputePipelineState = compute_pipeline_state
		else {
			command_encoder = nil
			return
		}
		command_encoder?.setComputePipelineState(pipeline_state)
		let grid: MTLSize = MTLSize(width: thread, height: 1, depth: 1)
		let k: Int = pipeline_state.maxTotalThreadsPerThreadgroup
		let subgrid: MTLSize = MTLSize(width: k, height: 1, depth: 1)
		command_encoder?.dispatchThreads(grid, threadsPerThreadgroup: subgrid)
	}
	func end(){
		command_encoder?.endEncoding()
	}
}
