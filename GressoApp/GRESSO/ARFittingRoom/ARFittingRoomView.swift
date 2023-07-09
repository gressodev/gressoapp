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
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State private var showingSnapshot = false
    @State private var needToTakeSnapshot = false
    @State private var needToDarkenLenses = false
    @State private var needToLightenLenses = false
    @State private var snapshotImage: UIImage?
    @State private var isModelLoading = true
    @State private var currentIndex: Int = .zero
    
    @State private var lensDarkness: Double = LocalConstants.sliderMaxValue
    @State private var isSliderGoingDown = true
    
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
        ZStack {
            ARViewContainer(
                currentDestination: $currentDestination,
                needToTakeSnapshot: $needToTakeSnapshot,
                needToDarkenLenses: $needToDarkenLenses,
                needToLightenLenses: $needToLightenLenses,
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
                        Slider(value: $lensDarkness, in: 0...LocalConstants.sliderMaxValue)
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
                        lensDarkness = LocalConstants.sliderMaxValue
                        isSliderGoingDown = true
                        currentIndex = index
                        isModelLoading = loadingModels[index].isLoading
                        guard let url = loadingModels.item(at: index)?.url else { return }
                        currentDestination = url
                        isPhotochromic = url.absoluteString.contains("purple")
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
            lensDarkness = LocalConstants.sliderMaxValue
            guard let model = models.first(where: { $0.id == currentIndex }) else { return }
            isModelLoading = model.isLoading
            guard let url = model.url else { return }
            currentDestination = url
            isPhotochromic = url.absoluteString.contains("purple")
            isSliderGoingDown = true
        }
        .onChange(of: isSliderGoingDown) { isGoingDown in
            needToLightenLenses = !isGoingDown
            needToDarkenLenses = isGoingDown
        }
        .onReceive(timer) { _ in
            guard isPhotochromic else { return }
            withAnimation {
                if isSliderGoingDown && lensDarkness != .zero {
                    lensDarkness -= 1
                    if lensDarkness == .zero {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isSliderGoingDown = false
                        }
                    }
                } else if !isSliderGoingDown && lensDarkness != LocalConstants.sliderMaxValue {
                    lensDarkness += 1
                    if lensDarkness == LocalConstants.sliderMaxValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isSliderGoingDown = true
                        }
                    }
                }
            }
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
