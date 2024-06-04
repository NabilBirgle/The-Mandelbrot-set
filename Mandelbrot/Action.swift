enum Action: Equatable, Comparable {
	case update_color(Int)
	case refresh(Int)
	case start(Int)
	case set_window(Int)
	case set_radius(Int)
	case set_center(Int)
	case set_delta_v(Int)
	case set_magnify(Int)
	case set_background(Int)
	case loading(Int)
}
