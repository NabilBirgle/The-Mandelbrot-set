enum Action: Equatable, Comparable {
	case update_color(Int)
	case refresh(Int)
	case start(Int)
	case new_parameter(Int)
	case loading(Int)
}
