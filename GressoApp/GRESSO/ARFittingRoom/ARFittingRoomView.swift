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
    
    private enum LocalConstants {
        static let sliderMaxValue: Double = 20
    }
    
    @Environment(\.dismiss) var dismiss
        
    @State private var showingSnapshot = false
    @State private var needToTakeSnapshot = false
    @State private var snapshotImage: UIImage?
    @State private var isModelLoading = true
    @State private var currentIndex: Int = .zero
    
    @State private var lensDarkness: Double = LocalConstants.sliderMaxValue
    @State private var isSliderGoingDown = false
    
    @State private var showingShareScreen = false
    
    @State private var isPhotochromic = false
    
    @Binding var loadingModels: [LoadingModel]
    private var modelLink: URL?
    @State private var currentDestination: URL?
    
    init(loadingModels: Binding<[LoadingModel]>, modelLink: URL?) {
        self._loadingModels = loadingModels
        self.modelLink = modelLink
    }
    
    var body: some View {
        let slider = SliderView(isSliderGoingDown: $isSliderGoingDown)
        
        ZStack {
            ARViewContainer(
                currentDestination: $currentDestination,
                needToTakeSnapshot: $needToTakeSnapshot,
                isSliderGoingDown: $isSliderGoingDown,
                didTakeSnapshot: { image in
                    snapshotImage = image
                }
            )
            
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
                
                if isPhotochromic {
                    HStack {
                        Spacer()
                        slider
                            .rotationEffect(.degrees(-90.0), anchor: .trailing)
                            .disabled(true)
                            .frame(width: 250)
                            .padding(.trailing, 40)
                            .padding(.bottom, 200)
                    }
                    
                    Spacer()
                }
                
                ZStack {
                    ColorsView(models: $loadingModels) { index in
                        currentIndex = index
                        isModelLoading = loadingModels[index].isLoading
                        guard let url = loadingModels.item(at: index)?.url else { return }
                        currentDestination = url
                        isPhotochromic = url.absoluteString.contains("blue")
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
            isPhotochromic = url.absoluteString.contains("blue")
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

struct ARFittingRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ARFittingRoomView(loadingModels: .constant([]), modelLink: nil)
    }
}
