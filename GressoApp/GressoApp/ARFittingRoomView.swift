//
//  ARFittingRoomView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 18.06.2023.
//

import SwiftUI
import RealityKit
 
struct ARFittingRoomView: View {
    @Environment(\.dismiss) var dismiss
    
    let destinations: [URL]
    
    @State private var tabIndex: Int = .zero
    @State private var currentDestination: URL?
    
    var body: some View {
        let arView = ARViewContainer(
            currentDestination: Binding(
                get: {
                    destinations[tabIndex]
                }, set: { _ in }
            )
        )
        
        ZStack {
            arView
            VStack {
                Button("dismiss") {
                    dismiss()
                }
                .padding()
                Spacer()
            }
            VStack {
                Spacer()

                TabView(selection: $tabIndex) {
                    ForEach(Array(zip(destinations.indices, destinations)), id: \.0) { index, destination in
                        Text(destination.lastPathComponent)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 150)
                .background(.green)
            }
        }
        .ignoresSafeArea(.all)
    }
}
