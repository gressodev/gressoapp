//
//  ARFittingRoomView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 18.06.2023.
//

import SwiftUI

class ModelEntityProvider: ObservableObject {
    
    @Published var modelDestination: URL? = nil
    
    func changeDestination(destination: URL) {
        modelDestination = destination
    }
}

struct ARFittingRoomView: View {
    
    let destinations: [URL]
    
    @State private var tabIndex: Int = .zero
    
    var body: some View {
        let arView = ARViewContainer(destinations: destinations, currentIndex: $tabIndex)
        ZStack {
            arView
            
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

struct ARFittingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ARFittingRoomView(destinations: [])
    }
}
