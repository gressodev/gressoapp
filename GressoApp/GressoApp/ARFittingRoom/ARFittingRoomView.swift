//
//  ARFittingRoomView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 18.06.2023.
//

import SwiftUI
import RealityKit

@MainActor
struct ARFittingRoomView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showingSnapshot = false
    @State private var needToTakeSnapshot = false
    @State private var snapshotImage: UIImage?
    
    @State private var showingShareScreen = false
    
    let destinations: [URL]
    private var modelLink: URL?
    @State private var currentDestination: URL?
    
    init(destinations: [URL], modelLink: URL?) {
        self.destinations = destinations
        self.modelLink = modelLink
        currentDestination = destinations.first
    }
    
    var body: some View {
        let arView = ARViewContainer(
            currentDestination: $currentDestination,
            needToTakeSnapshot: $needToTakeSnapshot,
            didTakeSnapshot: { image in
                snapshotImage = image
            }
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
                    
                    Spacer()
                    
                    if #available(iOS 16.0, *) {
                        if let modelLink {
                            ShareLink(item: modelLink) {
                                Image(systemName: Assets.Images.shareImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .shadow(radius: 5)
                                    .foregroundColor(.white)
                            }
                        }
                    } else {
                        Button {
                            showingShareScreen = true
                        } label: {
                            Image(systemName: Assets.Images.shareImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .shadow(radius: 5)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.top, 70)
                .padding(.leading, 30)
                .padding(.trailing, 30)
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
                        
                        Button {
                            needToTakeSnapshot = true
                        } label: {
                            Circle()
                                .strokeBorder(.white, lineWidth: 8)
                                .frame(width: 80, height: 80)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
        .onChange(of: snapshotImage) { _ in
            showingSnapshot = true
        }
        .sheet(isPresented: $showingSnapshot) {
            if let snapshotImage {
                SnapshotView(snapshot: snapshotImage)
            }
        }
        .sheet(isPresented: $showingShareScreen) {
            if let modelLink {
                ActivityView(items: [modelLink])
            }
        }
    }
}
