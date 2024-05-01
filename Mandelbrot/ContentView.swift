//
//  ContentView.swift
//  test
//
//  Created by Nabil Birgle on 26/04/2024.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack {
			MetalView()
				.border(Color.black, width: 2)
			Text("Hello, Metal !")
		}
		.padding()
	}
}

#Preview {
    ContentView()
}
