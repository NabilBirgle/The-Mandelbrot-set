enum Action {
	case update_color(Int)
	case refresh(Int)
	case start(Int)
	case set_window(Float, Float)
	case set_radius(Float)
	case set_center(Float, Float)
	case set_delta_v(Float, Float)
	case set_magnify(Float)
	case set_background(Bool)
	case loading(Int)
}
func ==(a: Action?, b: Action?) ->  Bool{
	switch a {
	case .update_color(let frame_a):
		switch b {
		case .update_color(let frame_b):
			return frame_a == frame_b
		default:
			return false
		}
	case .refresh(let frame_a):
		switch b {
		case .refresh(let frame_b):
			return frame_a == frame_b
		default:
			return false
		}
	case .start(let frame_a):
		switch b {
		case .start(let frame_b):
			return frame_a == frame_b
		default:
			return false
		}
	case .set_window(_, _):
		switch b {
		case .set_window(_, _):
			return true
		default:
			return false
		}
	case .set_radius(_):
		switch b {
		case .set_radius(_):
			return true
		default:
			return false
		}
	case .set_center(_, _):
		switch b {
		case .set_center(_, _):
			return true
		default:
			return false
		}
	case .set_delta_v(_, _):
		switch b {
		case .set_delta_v(_, _):
			return true
		default:
			return false
		}
	case .set_magnify(_):
		switch b {
		case .set_magnify(_):
			return true
		default:
			return false
		}
	case .set_background(_):
		switch b {
		case .set_background(_):
			return true
		default:
			return false
		}
	case .loading(let frame_a):
		switch b {
		case .loading(let frame_b):
			return frame_a == frame_b
		default:
			return false
		}
	default:
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return false
		case .set_radius(_):
			return false
		case .set_center(_, _):
			return false
		case .set_delta_v(_, _):
			return false
		case .set_magnify(_):
			return false
		case .set_background(_):
			return false
		case .loading(_):
			return false
		default:
			return true
		}
	}
}
func <=(a: Action?, b: Action?) ->  Bool{
	switch a {
	case .update_color(let frame_a):
		switch b {
		case .update_color(let frame_b):
			return frame_a<=frame_b
		case .refresh(_):
			return true
		case .start(_):
			return true
		case .set_window(_, _):
			return true
		case .set_radius(_):
			return true
		case .set_center(_, _):
			return true
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .refresh(let frame_a):
		switch b {
		case .update_color(_):
			return false
		case .refresh(let frame_b):
			return frame_a<=frame_b
		case .start(_):
			return true
		case .set_window(_, _):
			return true
		case .set_radius(_):
			return true
		case .set_center(_, _):
			return true
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .start(let frame_a):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(let frame_b):
			return frame_a<=frame_b
		case .set_window(_, _):
			return true
		case .set_radius(_):
			return true
		case .set_center(_, _):
			return true
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .set_window(_, _):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return true
		case .set_radius(_):
			return true
		case .set_center(_, _):
			return true
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .set_radius(_):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return false
		case .set_radius(_):
			return true
		case .set_center(_, _):
			return true
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .set_center(_, _):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return false
		case .set_radius(_):
			return false
		case .set_center(_, _):
			return true
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .set_delta_v(_, _):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return false
		case .set_radius(_):
			return false
		case .set_center(_, _):
			return false
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .set_magnify(_):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return false
		case .set_radius(_):
			return false
		case .set_center(_, _):
			return false
		case .set_delta_v(_, _):
			return false
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .set_background(_):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return false
		case .set_radius(_):
			return false
		case .set_center(_, _):
			return false
		case .set_delta_v(_, _):
			return false
		case .set_magnify(_):
			return false
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return false
		}
	case .loading(let frame_a):
		switch b {
		case .update_color(_):
			return false
		case .refresh(_):
			return false
		case .start(_):
			return false
		case .set_window(_, _):
			return false
		case .set_radius(_):
			return false
		case .set_center(_, _):
			return false
		case .set_delta_v(_, _):
			return false
		case .set_magnify(_):
			return false
		case .set_background(_):
			return false
		case .loading(let frame_b):
			return frame_a<=frame_b
		default:
			return false
		}
	default:
		switch b {
		case .update_color(_):
			return true
		case .refresh(_):
			return true
		case .start(_):
			return true
		case .set_window(_, _):
			return true
		case .set_radius(_):
			return true
		case .set_center(_, _):
			return true
		case .set_delta_v(_, _):
			return true
		case .set_magnify(_):
			return true
		case .set_background(_):
			return true
		case .loading(_):
			return true
		default:
			return true
		}
	}
}
