func pow(_ x: Int, _ y: Int) -> Int {
	y == 0 ? 1 : pow(x, y-1)*x
}
