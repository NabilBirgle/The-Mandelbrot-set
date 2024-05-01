import simd

class Mesh {
	var n: UInt32
	var vertices: [simd_float2]
	var triangles: [UInt32]
	init(n: UInt32) {
		self.n = n
		self.vertices = []
		self.triangles = []
		for j in 0...n {
			for i in 0...n {
				self.vertices.append([Float(i), Float(j)] / Float(n))
			}
		}
		var k: UInt32 = (n+1)*(n+1)
		for j in 0..<n {
			for i in 0..<n {
				let v: simd_float2 = (
					[Float(i), Float(j)]
					+ [Float(i+1), Float(j+1)]
				) / Float(2*n)
				self.vertices.append(v)
				self.triangles.append(m(i: i,   j: j))
				self.triangles.append(m(i: i+1, j: j))
				self.triangles.append(k)
				self.triangles.append(m(i: i+1, j: j))
				self.triangles.append(m(i: i+1, j: j+1))
				self.triangles.append(k)
				self.triangles.append(m(i: i+1, j: j+1))
				self.triangles.append(m(i: i,   j: j+1))
				self.triangles.append(k)
				self.triangles.append(m(i: i, j: j+1))
				self.triangles.append(m(i: i, j: j))
				self.triangles.append(k)
				k += 1
			}
		}
	}
	func m(i: UInt32, j: UInt32) -> UInt32 {
		i + j*(n+1)
	}
}
