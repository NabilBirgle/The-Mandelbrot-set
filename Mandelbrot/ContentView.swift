//
//  ContentView.swift
//  test
//
//  Created by Nabil Birgle on 26/04/2024.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		MetalView()
			.border(Color.black, width: 0)
			.preferredColorScheme(.light)
	}
}

#Preview {
    ContentView()
}
