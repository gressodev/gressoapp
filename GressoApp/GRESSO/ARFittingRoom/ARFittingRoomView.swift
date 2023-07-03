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
    @State private var isModelLoading = true
    @State private var currentIndex: Int = .zero
    
    @State private var showingShareScreen = false
    
    @Binding var loadingModels: [LoadingModel]
    private var modelLink: URL?
    @State private var currentDestination: URL?
    
    init(loadingModels: Binding<[LoadingModel]>, modelLink: URL?) {
        self._loadingModels = loadingModels
        self.modelLink = modelLink
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
                    ColorsView(models: $loadingModels) { index in
                        currentIndex = index
                        isModelLoading = loadingModels[index].isLoading
                        guard let url = loadingModels.item(at: index)?.url else { return }
                        currentDestination = url
                    }
                    
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
                .frame(height: 150)
            }
            
            if isModelLoading {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .ignoresSafeArea(.all)
        .onChange(of: snapshotImage) { _ in
            showingSnapshot = true
        }
        .onChange(of: loadingModels) { models in
            guard let model = models.first(where: { $0.id == currentIndex }) else { return }
            isModelLoading = model.isLoading
            guard let url = model.url else { return }
            currentDestination = url
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
