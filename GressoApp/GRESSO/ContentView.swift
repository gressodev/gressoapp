//
//  ContentView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 07.06.2023.
//

import SwiftUI
import ARKit

enum ActiveTab: Int {
    case home = 0
    case glass = 1
    case wishlist = 2
    case bag = 3
}

struct ContentView : View {
    
    private enum LocalConstants {
        static let navBarHeight: CGFloat = 50
        
        enum VirtualTryOnButton {
            static let height: CGFloat = 40
            static let cornerRadius: CGFloat = 20
            static let topBottomPadding: CGFloat = 3
            static let backgroundOpacity: Double = 0.1
        }
    }
    
    private let isARFaceTrackingConfigurationSupported = ARFaceTrackingConfiguration.isSupported
    
    @State private var loadingModels: [LoadingModel] = []
    @State private var modelsCount: Int = .zero
    
    @State private var showingAR = false
    
    @StateObject private var s3Service = S3ServiceHandler()
    
    @State private var activeTab: ActiveTab = .glass
    
    @StateObject var homeModel = WebViewModel(urlString: "https://gresso.com")
    @StateObject var glassModel = WebViewModel(urlString: "https://gresso.com/pages/ar")
    @StateObject var wishlistModel = WebViewModel(urlString: "https://gresso.com/apps/wishlist")
    @StateObject var bagModel = WebViewModel(urlString: "https://gresso.com/cart")
    
    @State private var doGlassesHaveModelHomeTab = false
    @State private var doGlassesHaveModelGlassTab = false
    @State private var doGlassesHaveModelWishlistTab = false
    @State private var doGlassesHaveModelBagTab = false
    @State private var isPageLoading = false
    
    var body: some View {
        let homeView = WebView(webView: homeModel.webView)
        let glassView = WebView(webView: glassModel.webView)
        let wishlistView = WebView(webView: wishlistModel.webView)
        let bagView = WebView(webView: bagModel.webView)
        
        TabView(selection: $activeTab) {
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text("GRESSO")
                            .font(.system(size: 30, weight: .bold))
                        Spacer()
                    }
                    
                    HStack {
                        if homeModel.canGoBack {
                            Button {
                                homeModel.goBack()
                            } label: {
                                Image(systemName: Assets.Images.chevronBackward)
                                    .renderingMode(.template)
                            }
                            .padding()
                        } else {
                            Button {
                                homeModel.openMenu()
                            } label: {
                                Image(Assets.Images.menuButtonIcon)
                                    .renderingMode(.template)
                            }
                            .padding()
                        }
                        
                        Spacer()
                        
                        if isPageLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                
                homeView
                
                if doGlassesHaveModelHomeTab {
                    HStack {
                        Button {
                            showingAR = true
                        } label: {
                            Image(Assets.Images.virtualTryOnIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: LocalConstants.VirtualTryOnButton.height)
                        }
                        .background(.black.opacity(LocalConstants.VirtualTryOnButton.backgroundOpacity))
                        .cornerRadius(LocalConstants.VirtualTryOnButton.cornerRadius)
                        .padding(.top, LocalConstants.VirtualTryOnButton.topBottomPadding)
                        .padding(.bottom, LocalConstants.VirtualTryOnButton.topBottomPadding)
                    }
                }
            }
            .tabItem {
                Image(Assets.Images.TabBar.tabItemHome)
                    .renderingMode(.template)
            }
            .tag(ActiveTab.home)
            
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text("GRESSO")
                            .font(.system(size: 30, weight: .bold))
                        Spacer()
                    }
                    
                    HStack {
                        Button {
                            glassModel.goBack()
                        } label: {
                            Image(systemName: Assets.Images.chevronBackward)
                                .renderingMode(.template)
                        }
                        .padding()
                        .disabled(!glassModel.canGoBack)
                        
                        Spacer()
                        
                        if isPageLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                
                glassView
                
                if doGlassesHaveModelGlassTab {
                    HStack {
                        Button {
                            showingAR = true
                        } label: {
                            Image(Assets.Images.virtualTryOnIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: LocalConstants.VirtualTryOnButton.height)
                        }
                        .background(.black.opacity(LocalConstants.VirtualTryOnButton.backgroundOpacity))
                        .cornerRadius(LocalConstants.VirtualTryOnButton.cornerRadius)
                        .padding(.top, LocalConstants.VirtualTryOnButton.topBottomPadding)
                        .padding(.bottom, LocalConstants.VirtualTryOnButton.topBottomPadding)
                    }
                }
            }
            .tabItem {
                Image(Assets.Images.menuButtonIcon)
                    .renderingMode(.template)
            }
            .tag(ActiveTab.glass)
            
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text("GRESSO")
                            .font(.system(size: 30, weight: .bold))
                        Spacer()
                    }
                    
                    HStack {
                        Button {
                            wishlistModel.goBack()
                        } label: {
                            Image(systemName: Assets.Images.chevronBackward)
                                .renderingMode(.template)
                        }
                        .padding()
                        .disabled(!wishlistModel.canGoBack)
                        
                        Spacer()
                        
                        if isPageLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                
                wishlistView
                
                if doGlassesHaveModelWishlistTab {
                    HStack {
                        Button {
                            showingAR = true
                        } label: {
                            Image(Assets.Images.virtualTryOnIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: LocalConstants.VirtualTryOnButton.height)
                        }
                        .background(.black.opacity(LocalConstants.VirtualTryOnButton.backgroundOpacity))
                        .cornerRadius(LocalConstants.VirtualTryOnButton.cornerRadius)
                        .padding(.top, LocalConstants.VirtualTryOnButton.topBottomPadding)
                        .padding(.bottom, LocalConstants.VirtualTryOnButton.topBottomPadding)
                    }
                }
            }
            .tabItem {
                Image(systemName: Assets.Images.heart)
                    .renderingMode(.template)
            }
            .tag(ActiveTab.wishlist)
            
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text("GRESSO")
                            .font(.system(size: 30, weight: .bold))
                        Spacer()
                    }
                    
                    HStack {
                        Button {
                            bagModel.goBack()
                        } label: {
                            Image(systemName: Assets.Images.chevronBackward)
                                .renderingMode(.template)
                        }
                        .padding()
                        .disabled(!bagModel.canGoBack)
                        
                        Spacer()
                        
                        if isPageLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                
                bagView
                    .onAppear {
                        bagModel.reload()
                    }
                
                if doGlassesHaveModelBagTab {
                    HStack {
                        Button {
                            showingAR = true
                        } label: {
                            Image(Assets.Images.virtualTryOnIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: LocalConstants.VirtualTryOnButton.height)
                        }
                        .background(.black.opacity(LocalConstants.VirtualTryOnButton.backgroundOpacity))
                        .cornerRadius(LocalConstants.VirtualTryOnButton.cornerRadius)
                        .padding(.top, LocalConstants.VirtualTryOnButton.topBottomPadding)
                        .padding(.bottom, LocalConstants.VirtualTryOnButton.topBottomPadding)
                    }
                }
            }
            .tabItem {
                VStack {
                    Image(Assets.Images.TabBar.tabItemBag)
                        .renderingMode(.template)
                }
            }
            .tag(ActiveTab.bag)
        }
        .onAppear {
            homeModel.reloadWishlistCompletion = {
                wishlistModel.reload()
            }
            glassModel.reloadWishlistCompletion = {
                wishlistModel.reload()
            }
            bagModel.reloadWishlistCompletion = {
                wishlistModel.reload()
            }
        }
        .fullScreenCover(isPresented: $showingAR) {
            var modelLink: URL? {
                switch activeTab {
                case .home:
                    return homeModel.urlChanges
                case .glass:
                    return glassModel.urlChanges
                case .wishlist:
                    return wishlistModel.urlChanges
                case .bag:
                    return bagModel.urlChanges
                }
            }
            ARFittingRoomView(
                loadingModels: $loadingModels,
                modelLink: modelLink
            )
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: homeModel.urlChanges) { url in
            guard let url, isARFaceTrackingConfigurationSupported else { return }
            isPageLoading = true
            
            s3Service.filesCount(folderName: url.lastPathComponent) { count in
                loadingModels = []
                for index in 0..<count {
                    let model = LoadingModel(id: index, url: nil, isLoading: true)
                    loadingModels.append(model)
                }
                modelsCount = count
                if count != .zero {
                    s3Service.downloadFilesInFolder(folderName: url.lastPathComponent) { url, image in
                        guard let index = loadingModels.firstIndex(where: { $0.isLoading }) else { return }
                        loadingModels[index].url = url
                        loadingModels[index].isLoading = false
                        loadingModels[index].colorImage = image
                    }
                    withAnimation {
                        doGlassesHaveModelHomeTab = true
                        isPageLoading = false
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModelHomeTab = false
                        isPageLoading = false
                    }
                }
            }
        }
        .onChange(of: glassModel.urlChanges) { url in
            guard let url, isARFaceTrackingConfigurationSupported else { return }
            isPageLoading = true
            
            s3Service.filesCount(folderName: url.lastPathComponent) { count in
                loadingModels = []
                for index in 0..<count {
                    let model = LoadingModel(id: index, url: nil, isLoading: true)
                    loadingModels.append(model)
                }
                modelsCount = count
                if count != .zero {
                    s3Service.downloadFilesInFolder(folderName: url.lastPathComponent) { url, image in
                        guard let index = loadingModels.firstIndex(where: { $0.isLoading }) else { return }
                        loadingModels[index].url = url
                        loadingModels[index].isLoading = false
                        loadingModels[index].colorImage = image
                    }
                    withAnimation {
                        doGlassesHaveModelGlassTab = true
                        isPageLoading = false
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModelGlassTab = false
                        isPageLoading = false
                    }
                }
            }
        }
        .onChange(of: wishlistModel.urlChanges) { url in
            guard let url, isARFaceTrackingConfigurationSupported else { return }
            isPageLoading = true
            
            s3Service.filesCount(folderName: url.lastPathComponent) { count in
                loadingModels = []
                for index in 0..<count {
                    let model = LoadingModel(id: index, url: nil, isLoading: true)
                    loadingModels.append(model)
                }
                modelsCount = count
                if count != .zero {
                    s3Service.downloadFilesInFolder(folderName: url.lastPathComponent) { url, image in
                        guard let index = loadingModels.firstIndex(where: { $0.isLoading }) else { return }
                        loadingModels[index].url = url
                        loadingModels[index].isLoading = false
                        loadingModels[index].colorImage = image
                    }
                    withAnimation {
                        doGlassesHaveModelWishlistTab = true
                        isPageLoading = false
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModelWishlistTab = false
                        isPageLoading = false
                    }
                }
            }
        }
        .onChange(of: bagModel.urlChanges) { url in
            guard let url, isARFaceTrackingConfigurationSupported else { return }
            isPageLoading = true
            
            s3Service.filesCount(folderName: url.lastPathComponent) { count in
                loadingModels = []
                for index in 0..<count {
                    let model = LoadingModel(id: index, url: nil, isLoading: true)
                    loadingModels.append(model)
                }
                modelsCount = count
                if count != .zero {
                    s3Service.downloadFilesInFolder(folderName: url.lastPathComponent) { url, image in
                        guard let index = loadingModels.firstIndex(where: { $0.isLoading }) else { return }
                        loadingModels[index].url = url
                        loadingModels[index].isLoading = false
                        loadingModels[index].colorImage = image
                    }
                    withAnimation {
                        doGlassesHaveModelBagTab = true
                        isPageLoading = false
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModelBagTab = false
                        isPageLoading = false
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
