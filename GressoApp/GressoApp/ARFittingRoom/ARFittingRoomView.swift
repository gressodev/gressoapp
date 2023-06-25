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
    @State private var currentDestination: URL?
    
    var body: some View {
        let arView = ARViewContainer(
            currentDestination: $currentDestination
        )
        
        ZStack {
            arView
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: Assets.Images.xmarkCircleFill)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .shadow(radius: 5)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 70)
                    .padding(.leading, 30)
                    
                    Spacer()
                    
                    Button {
                        arView.saveSnapshot(saveToHDR: false)
                    } label: {
                        Image(systemName: Assets.Images.photoСircle)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .shadow(radius: 5)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 70)
                    .padding(.trailing, 30)
                }
                Spacer()
            }
            VStack {
                Spacer()
                
                ZStack {
                    ColorsView(dataSource: destinations.map { $0.lastPathComponent }) { index in
                        currentDestination = destinations[index]
                    }
                    .frame(height: 150)
                    
                    HStack {
                        Spacer()
                        
                        Circle()
                            .strokeBorder(.white, lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}
