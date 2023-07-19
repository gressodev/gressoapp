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
        static let navBarHeight: CGFloat = 44
        static let gressoLabel = "GRESSO"
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
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .white
    }
    
    var body: some View {
        let homeView = WebView(webView: homeModel.webView)
        let glassView = WebView(webView: glassModel.webView)
        let wishlistView = WebView(webView: wishlistModel.webView)
        let bagView = WebView(webView: bagModel.webView)
        
        TabView(selection: $activeTab) {
            VStack {
                VStack {
                    Spacer()
                    ZStack {
                        HStack {
                            Spacer()
                            Text(LocalConstants.gressoLabel)
                                .font(Fonts.jostMedium20)
                            Spacer()
                        }
                        
                        HStack {
                            if homeModel.canGoBack {
                                Button {
                                    homeModel.goBack()
                                } label: {
                                    Image(systemName: Images.chevronBackward)
                                        .renderingMode(.template)
                                }
                                .padding(.leading)
                            } else {
                                Button {
                                    homeModel.openMenu()
                                } label: {
                                    Image(Images.menuButtonIcon)
                                        .renderingMode(.template)
                                }
                                .padding(.leading)
                            }
                            
                            Spacer()
                            
                            if isPageLoading {
                                ProgressView()
                                    .padding(.trailing)
                            }
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
                            GressoStyiledButton(
                                image: Images.stars,
                                text: Localizable.tryOn()
                            )
                        }
                    }
                }
            }
            .tabItem {
                let image = activeTab == .home ? Image(uiImage: Images.homeActive) : Image(uiImage: Images.home)
                image
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                    .padding(.top, 14)
            }
            .tag(ActiveTab.home)
            
            VStack {
                VStack {
                    Spacer()
                    ZStack {
                        HStack {
                            Spacer()
                            Text(LocalConstants.gressoLabel)
                                .font(Fonts.jostMedium20)
                            Spacer()
                        }
                        
                        HStack {
                            Button {
                                glassModel.goBack()
                            } label: {
                                Image(systemName: Images.chevronBackward)
                                    .renderingMode(.template)
                            }
                            .padding(.leading)
                            .disabled(!glassModel.canGoBack)
                            
                            Spacer()
                            
                            if isPageLoading {
                                ProgressView()
                                    .padding(.trailing)
                            }
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
                            GressoStyiledButton(
                                image: Images.stars,
                                text: Localizable.tryOn()
                            )
                        }
                    }
                }
            }
            .tabItem {
                let image = activeTab == .glass ? Image(uiImage: Images.squaresActive) : Image(uiImage: Images.squares)
                image
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                    .padding(.top, 14)
            }
            .tag(ActiveTab.glass)
            
            VStack {
                VStack {
                    Spacer()
                    ZStack {
                        HStack {
                            Spacer()
                            Text(LocalConstants.gressoLabel)
                                .font(Fonts.jostMedium20)
                            Spacer()
                        }
                        
                        HStack {
                            Button {
                                wishlistModel.goBack()
                            } label: {
                                Image(systemName: Images.chevronBackward)
                                    .renderingMode(.template)
                            }
                            .padding(.leading)
                            .disabled(!wishlistModel.canGoBack)
                            
                            Spacer()
                            
                            if isPageLoading {
                                ProgressView()
                                    .padding(.trailing)
                            }
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
                            GressoStyiledButton(
                                image: Images.stars,
                                text: Localizable.tryOn()
                            )
                        }
                    }
                }
            }
            .tabItem {
                let image = activeTab == .wishlist ? Image(uiImage: Images.favoritesActive) : Image(uiImage: Images.favorites)
                image
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                    .padding(.top, 14)
            }
            .tag(ActiveTab.wishlist)
            
            VStack {
                VStack {
                    Spacer()
                    ZStack {
                        HStack {
                            Spacer()
                            Text(LocalConstants.gressoLabel)
                                .font(Fonts.jostMedium20)
                            Spacer()
                        }
                        
                        HStack {
                            Button {
                                bagModel.goBack()
                            } label: {
                                Image(systemName: Images.chevronBackward)
                                    .renderingMode(.template)
                            }
                            .padding(.leading)
                            .disabled(!bagModel.canGoBack)
                            
                            Spacer()
                            
                            if isPageLoading {
                                ProgressView()
                                    .padding(.trailing)
                            }
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
                            GressoStyiledButton(
                                image: Images.stars,
                                text: Localizable.tryOn()
                            )
                        }
                    }
                }
            }
            .tabItem {
                let image = activeTab == .bag ? Image(uiImage: Images.bagActive) : Image(uiImage: Images.bag)
                image
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                    .padding(.top, 14)
            }
            .tag(ActiveTab.bag)
        }
        .preferredColorScheme(ColorScheme.dark)
        .tint(.white)
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
            let name = modelLink?
                .lastPathComponent
                .replacingOccurrences(of: "-titanium", with: "")
                .uppercased() ?? ""
            
            ARFittingRoomView(
                loadingModels: $loadingModels,
                modelLink: modelLink,
                modelName: name
            )
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: homeModel.urlChanges) { url in
            loadGlasses(url: url) { have in
                doGlassesHaveModelHomeTab = have
            }
        }
        .onChange(of: glassModel.urlChanges) { url in
            loadGlasses(url: url) { have in
                doGlassesHaveModelGlassTab = have
            }
        }
        .onChange(of: wishlistModel.urlChanges) { url in
            loadGlasses(url: url) { have in
                doGlassesHaveModelWishlistTab = have
            }
        }
        .onChange(of: bagModel.urlChanges) { url in
            loadGlasses(url: url) { have in
                doGlassesHaveModelBagTab = have
            }
        }
    }
    
    private func loadGlasses(url: URL?, completion: @escaping (Bool) -> Void) {
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
                    completion(true)
                    isPageLoading = false
                }
            } else {
                withAnimation {
                    completion(false)
                    isPageLoading = false
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
