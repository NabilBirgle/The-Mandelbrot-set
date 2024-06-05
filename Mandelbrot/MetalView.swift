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
	private let gpu: GPU
	private let command_queue: Command_queue
	@State private var metalView: MTKView
	init(){
		self.gpu = GPU()
		self.command_queue = Command_queue(gpu: gpu)
		self.metalView = MTKView()
		metalView.device = gpu.get_device()
		metalView.clearColor = Clear_color()
	}
	@State private var window_width: CGFloat = 0
	@State private var window_height: CGFloat = 0
	@State private var center: (Float, Float) = (0, 0)
	@State private var zoom: Int = 0
	private let zoom_min: Int = 0
	private let zoom_max: Int = 30
	func radius(zoom: Int) -> Float {
		Float(2) / Float(pow(2, zoom))
	}
	@State private var window: Window?
	@State private var renderer: Renderer?
	var body: some View {
		ZStack(alignment: .topLeading){
			ZStack(alignment: .topTrailing){
				ZStack(alignment: .bottomLeading){
					ZStack(alignment: .bottomTrailing){
						MetalViewRepresentable(metalView: $metalView)
							.onAppear(perform: new_mandelbrot)
							.getSize(size_function: new_size)
							.gesture(drag_mandelbrot)
							.onTapGesture(count: 1, perform: show_button)
							.gesture(magnification)
						if !hidden { zoom_corner.padding() }
					}
					if !hidden { center_corner.padding() }
				}
				if !hidden { hide_corner.padding() }
			}
			if !hidden { background_corner.padding() }
		}
	}
	@State private var isWhite: Bool = true
	private var background_corner: some View {
		Menu("Background"){
			Button(action: {
				isWhite = true
				metalView.clearColor = Clear_color()
				color_mandelbrot()
			}) {
				Label("White", systemImage: isWhite ? "checkmark" : "")
					.labelStyle(.titleAndIcon)
			}
			Button(action: {
				isWhite = false
				metalView.clearColor = Clear_color()
				color_mandelbrot()
			}) {
				Label("Cream", systemImage: !isWhite ? "checkmark" : "")
					.labelStyle(.titleAndIcon)
			}
		}.frame(width: 120)
			.buttonStyle(.bordered)
	}
	func color_mandelbrot() {
		renderer?.CPU_parameters.isWhite = isWhite
		renderer?.add_setting(
			actions: [
				.new_parameter(0),
				.refresh(0),
				.update_color(0)
			]
		)
	}
	@State private var hidden: Bool = false
	func hide_button() -> Void {
		hidden = true
	}
	func show_button() -> Void {
		hidden = false
	}
	var hide_corner: some View {
		Button(action: hide_button){
			Label("Hide", systemImage: "eye")
		}
		.buttonStyle(.bordered)
	}
	@State private var input_x: String = ""
	@State private var input_y: String = ""
	@State private var input_zoom: String = ""
	@State private var show_alert: Bool = false
	private var center_corner: some View {
		Button(action: {
			let (x, y): (Float, Float) = center
			let zoom: Int = zoom
			input_x = "\(x)"
			input_y = "\(y)"
			input_zoom = "\(zoom)"
			show_alert = true
		}){
			let (x, y): (Float, Float) = center
			let text = "x: \(x)\ny: \(y)\nzoom: \(zoom)"
			Label(text, systemImage: "").lineLimit(3)
		}
		.buttonStyle(.bordered)
		.lineLimit(3, reservesSpace: true)
		.alert(
			"New coordinates",
			isPresented: $show_alert,
			actions: {
				TextField("x", text: $input_x)
				TextField("y", text: $input_y)
				TextField("zoom", text: $input_zoom)
				Button("Ok") {
					guard
						let x: Float = Float(input_x),
						let y: Float = Float(input_y),
						let z: Int = Int(input_zoom)
					else {
						return
					}
					if z < zoom_min || z > zoom_max {
						return
					}
					center = (x, y)
					zoom = z
					update_mandelbrot()
				}
				Button("Cancel", role: .cancel) {
				}
			}
		)
	}
	private var zoom_corner: some View {
		VStack {
			Button(action: zoom_mandelbrot){
				Label("+", systemImage: "")
					.labelStyle(.titleOnly)
			}
			Button(action: unzoom_mandelbrot){
				Label("-", systemImage: "")
					.labelStyle(.titleOnly)
			}
		}.buttonStyle(.bordered)
	}
	func update_mandelbrot(){
		let (x, y) = center
		let r = radius(zoom: zoom)
		renderer?.CPU_parameters.center = [x, y]
		renderer?.CPU_parameters.radius = r
		renderer?.add_setting(
			actions: [
				.loading(0),
				.new_parameter(0),
				.refresh(0),
				.update_color(0)
			]
		)
	}
	func new_size(size: CGSize) -> Void {
		window_width = size.width
		window_height = size.height
		renderer?.CPU_parameters.width = Float(window_width)
		renderer?.CPU_parameters.height = Float(window_height)
		renderer?.add_setting(
			actions: [
				.loading(0),
				.new_parameter(0),
				.refresh(0),
				.update_color(0)
			]
		)
	}
	func new_mandelbrot() -> Void {
		window = Window(
			gpu: gpu,
			center: center,
			radius: radius(zoom: zoom),
			width: Float(window_width),
			height: Float(window_height)
		)
		guard let w: Window = window else { return }
		renderer = Renderer(
			gpu: gpu,
			command_queue: command_queue,
			metalView: metalView,
			window: w,
			center: center,
			radius: radius(zoom: zoom),
			width: Float(window_width),
			height: Float(window_height)
		)
		metalView.delegate = renderer
	}
	private var drag_mandelbrot: some Gesture {
		DragGesture()
			.onChanged(dragging_mandelbrot)
			.onEnded(shift_mandelbrot)
	}
	func dragging_mandelbrot(d: DragGesture.Value){
		let (delta_x, delta_y): (Int, Int) = (
			Int(d.translation.width*100/window_width),
			-Int(d.translation.height*100/window_height)
		)
		let r: Float = radius(zoom: zoom)
		let w: Float = r * Float(window_width) / min(Float(window_width),Float(window_height))
		let h: Float = r * Float(window_height) / min(Float(window_width), Float(window_height))
		renderer?.CPU_parameters.delta_v = [Float(delta_x)*w/50,
											Float(delta_y)*h/50]
		renderer?.add_setting(action: .new_parameter(0))
	}
	func shift_mandelbrot(d: DragGesture.Value){
		let (delta_x, delta_y): (Int, Int) = (
			Int(d.translation.width*100/window_width),
			-Int(d.translation.height*100/window_height)
		)
		var (x, y): (Float, Float) = center
		let r = radius(zoom: zoom)
		let w = r * Float(window_width) / min(Float(window_width),Float(window_height))
		let h = r * Float(window_height) / min(Float(window_width), Float(window_height))
		x -= Float(delta_x) * w / 50
		y -= Float(delta_y) * h / 50
		center = (x, y)
		renderer?.CPU_parameters.center = [x, y]
		renderer?.CPU_parameters.delta_v = [0, 0]
		renderer?.add_setting(
			actions: [
				.loading(0),
				.new_parameter(0),
				.refresh(0),
				.update_color(0)
			]
		)
	}
	private var magnification: some Gesture {
		MagnifyGesture()
			.onChanged({value in
				let magnifyBy: Float = Float(value.magnification)
				renderer?.CPU_parameters.magnify = magnifyBy
				renderer?.add_setting(action: .new_parameter(0))
			})
			.onEnded({value in
				let magnifyBy: Float = Float(value.magnification)
				if magnifyBy > 2 {
					zoom_mandelbrot()
				} else if magnifyBy < 0.5 {
					unzoom_mandelbrot()
				} else {
					renderer?.CPU_parameters.magnify = 1
					renderer?.add_setting(action: .new_parameter(0))
				}
			})
	}
	func zoom_mandelbrot() {
		if zoom >= zoom_max{
			zoom = zoom_max
		} else {
			zoom += 1
		}
		let r = radius(zoom: zoom)
		renderer?.CPU_parameters.magnify = 1
		renderer?.CPU_parameters.radius = r
		renderer?.add_setting(
			actions: [
				.loading(0),
				.new_parameter(0),
				.refresh(0),
				.update_color(0)
			]
		)
	}
	func unzoom_mandelbrot(){
		if zoom <= zoom_min {
			zoom = zoom_min
		} else {
			zoom -= 1
		}
		let r = radius(zoom: zoom)
		renderer?.CPU_parameters.magnify = 1
		renderer?.CPU_parameters.radius = r
		renderer?.add_setting(
			actions: [
				.loading(0),
				.new_parameter(0),
				.refresh(0),
				.update_color(0)
			]
		)
	}
	func Clear_color() -> MTLClearColor {
		isWhite ? White_color() : Cream_color()
	}

	func White_color() -> MTLClearColor {
		MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
	}

	func Cream_color() -> MTLClearColor {
		MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
	}
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
