///// Copyright (c) 2023 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import MetalKit

struct MetalView: View {
	let gpu: GPU
	let command_queue: Command_queue
	let vertices_function = "vertices_function"
	let triangles_function = "triangles_function"
	let zero_function = "zero_function"
	let update_function =  "update_function"
	let vertex_main = "vertex_main"
	let fragment_main = "fragment_main"
	let n_vertex_buffer: Int = 3
	@State private var metalView: MTKView
	init(){
		let gpu = GPU()
		gpu.compile(name: vertices_function)
		gpu.compile(name: triangles_function)
		gpu.compile(name: zero_function)
		gpu.compile(name: update_function)
		gpu.compile(name: vertex_main)
		gpu.compile(name: fragment_main)
		self.gpu = gpu
		self.command_queue = Command_queue(gpu: gpu)
		self.metalView = MTKView()
		metalView.device = gpu.get_device()
		metalView.clearColor = Cream_color()
	}
	@State var window_width: CGFloat = 0
	@State var window_height: CGFloat = 0
	@State var center: (Float, Float) = (0, 0)
	@State var zoom: Int = 0
//	var radius: Float { get { Float(2) / Float(pow(2, zoom)) }}
	func radius(zoom: Int) -> Float {
		Float(2) / Float(pow(2, zoom))
	}
	@State var window: Window?
	@State private var renderer: Renderer?
	var body: some View {
		MetalViewRepresentable(metalView: $metalView)
			.scaledToFit()
			.onAppear(perform: new_mandelbrot)
			.getSize(size_function: new_size)
			.gesture(drag_mandelbrot)
			.onTapGesture(count: 2, perform: zoom_mandelbrot)


	}
	func new_size(size: CGSize) -> Void {
		window_height = size.height
		window_width = size.width
	}
	func new_mandelbrot() -> Void {
		window = Window(
			gpu: gpu,
			command_queue: command_queue,
			center: center,
			radius: radius(zoom: zoom),
			vertices_function: vertices_function,
			triangles_function: triangles_function,
			zero_function: zero_function
		)
		guard let w: Window = window else { return }
		renderer = Renderer(
			gpu: gpu,
			command_queue: command_queue,
			metalView: metalView,
			window: w,
			center: center,
			radius: radius(zoom: zoom),
			update_function: update_function,
			vertex_main: vertex_main,
			fragment_main: fragment_main,
			n_vertex_buffer: n_vertex_buffer
		)
		metalView.delegate = renderer
	}
	var drag_mandelbrot: some Gesture {
		DragGesture()
			.onChanged(dragging_mandelbrot)
			.onEnded(shift_mandelbrot)
	}
	func dragging_mandelbrot(d: DragGesture.Value){
		let (delta_x, delta_y): (Int, Int) = (
			Int(d.translation.width*100/window_width),
			-Int(d.translation.height*100/window_height)
		)
		let r = radius(zoom: zoom)
		renderer?.set_delta_v(
			delta_v: (Float(delta_x)*r/50, Float(delta_y)*r/50)
		)
	}
	func shift_mandelbrot(d: DragGesture.Value){
		let (delta_x, delta_y): (Int, Int) = (
			Int(d.translation.width*100/window_width),
			-Int(d.translation.height*100/window_height)
		)
		var (x, y): (Float, Float) = center
		let r = radius(zoom: zoom)
		x -= Float(delta_x) * r / 50
		y -= Float(delta_y) * r / 50
		center = (x, y)
		window?.set_vertices(
			gpu: gpu,
			command_queue: command_queue,
			vertices_function: vertices_function,
			center: center,
			radius: r
		)
		window?.mesh.set_z_n(
			gpu: gpu,
			command_queue: command_queue,
			zero_function: zero_function
		)
		renderer?.frame = 0
		renderer?.set_center(center: center)
		renderer?.set_delta_v(delta_v: (0, 0))
		renderer?.set_renderer(gpu: gpu,
							   update_function: update_function)
	}
	func zoom_mandelbrot(){
		zoom += 1
		let r = radius(zoom: zoom)
		window?.set_vertices(
			gpu: gpu,
			command_queue: command_queue,
			vertices_function: vertices_function,
			center: center,
			radius: r
		)
		window?.mesh.set_z_n(
			gpu: gpu,
			command_queue: command_queue,
			zero_function: zero_function
		)
		renderer?.frame = 0
		renderer?.set_radius(radius: r)
		renderer?.set_renderer(gpu: gpu,
							   update_function: update_function)
	}
}

func Cream_color() -> MTLClearColor {
	MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
}

extension View {
	func getSize(size_function: @escaping (CGSize) -> Void) -> some View {
		background(
			GeometryReader { geometry in
				Color.clear
					.preference(key: ViewPreferenceKey.self, value: geometry.size)
			}
		)
		.onPreferenceChange(ViewPreferenceKey.self, perform: size_function)
	}
}

private struct ViewPreferenceKey: PreferenceKey {
	static var defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
	}
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
	@Binding var metalView: MTKView
#if os(macOS)
	func makeNSView(context: Context) -> some NSView {
		metalView
	}
	func updateNSView(_ uiView: NSViewType, context: Context) {
		updateMetalView()
	}
#elseif os(iOS)
	func makeUIView(context: Context) -> MTKView {
		metalView
	}
	func updateUIView(_ uiView: MTKView, context: Context) {
		updateMetalView()
	}
#endif
	func updateMetalView() {
	}
}

#Preview {
	MetalView()
}
