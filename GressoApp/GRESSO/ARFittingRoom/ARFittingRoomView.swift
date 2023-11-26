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
    
    @State private var needToDarken = true
    
    @State private var showingShareScreen = false
    
    @State private var isPhotochromic = false
    
    @Binding var loadingModels: [LoadingModel]
    private var modelLink: URL?
    private let modelName: String
    @State private var currentDestination: URL?
    
    init(loadingModels: Binding<[LoadingModel]>, modelLink: URL?, modelName: String) {
        self._loadingModels = loadingModels
        self.modelLink = modelLink
        self.modelName = modelName
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(
                currentDestination: $currentDestination,
                needToTakeSnapshot: $needToTakeSnapshot,
                needToDarken: $needToDarken,
                didTakeSnapshot: { image in
                    snapshotImage = image
                }
            )
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                        AppStoreReviewManager.requestReviewIfAppropriate()
                    } label: {
                        HStack {
                            Image(uiImage: Images.cross)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(10)
                        }
                        .background(.black)
                        .cornerRadius(4)
                        .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(modelName)
                            .font(Fonts.jostRegular16)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .frame(height: 44)
                    }
                    .background(.black)
                    .cornerRadius(4)
                    
                    Spacer()
                    
                    // Пока отключил ShareLink, так как не получается навесить событие аналитики на нажатие
//                    if #available(iOS 16.0, *) {
//                        if let modelLink {
//                            ShareLink(item: modelLink) {
//                                HStack {
//                                    Image(uiImage: Images.share)
//                                        .resizable()
//                                        .frame(width: 24, height: 24)
//                                        .padding(10)
//                                }
//                                .background(.black)
//                                .cornerRadius(4)
//                                .frame(width: 44, height: 44)
//                            }
//                        }
//                    } else {
                        Button {
                            showingShareScreen = true
                            AnalyticsService.shared.shareTap()
                        } label: {
                            HStack {
                                Image(uiImage: Images.share)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(10)
                            }
                            .background(.black)
                            .cornerRadius(4)
                            .frame(width: 44, height: 44)
                        }
//                    }
                }
                .padding(.top, 54)
                .padding(.horizontal, 16)
                Spacer()
            }
            VStack {
                Spacer()
                
                VStack {
                    Spacer()
                    
                    if isPhotochromic {
                        SegmentedControl(needToDarken: $needToDarken)
                            .frame(height: 52)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 28)
                    }
                    
                    ZStack {
                        ColorsView(models: $loadingModels) { index in
                            currentIndex = index
                            isModelLoading = loadingModels[index].isLoading
                            guard let url = loadingModels.item(at: index)?.url else { return }
                            currentDestination = url
                            withAnimation {
                                isPhotochromic = url.absoluteString.contains("photochromic")
                            }
                        }

                        HStack {
                            Spacer()

                            Button {
                                needToTakeSnapshot = true
                                AnalyticsService.shared.photoTap()
                            } label: {
                                Circle()
                                    .strokeBorder(.clear, lineWidth: .zero)
                                    .frame(width: 80, height: 80)
                            }

                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    .padding(.bottom, 50)
                }
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
            withAnimation {
                isPhotochromic = url.absoluteString.contains("photochromic")
            }
        }
        .fullScreenCover(isPresented: $showingSnapshot) {
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
