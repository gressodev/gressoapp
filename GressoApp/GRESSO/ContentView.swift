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
        static let gressoUrl = (Locale.current.regionCode ?? "") == "RU" ? "gresso.ru" : "gresso.com"
    }
    
    private let isARFaceTrackingConfigurationSupported = ARFaceTrackingConfiguration.isSupported
    
    @State private var loadingModels: [LoadingModel] = []
    @State private var modelsCount: Int = .zero
    
    @State private var showingAR = false
    
    @StateObject private var s3Service = S3ServiceHandler()
    
    @State private var activeTab: ActiveTab = .glass
    
    @StateObject var homeModel = WebViewModel(
        urlString: "https://\(LocalConstants.gressoUrl)"
    )
    @StateObject var glassModel = WebViewModel(
        urlString: "https://\(LocalConstants.gressoUrl)/pages/ar"
    )
    @StateObject var wishlistModel = WebViewModel(
        urlString: "https://\(LocalConstants.gressoUrl)/apps/wishlist"
    )
    @StateObject var bagModel = WebViewModel(
        urlString: "https://\(LocalConstants.gressoUrl)/cart"
    )
    
    @State private var doGlassesHaveModelHomeTab = false
    @State private var doGlassesHaveModelGlassTab = false
    @State private var doGlassesHaveModelWishlistTab = false
    @State private var doGlassesHaveModelBagTab = false
    
    @State private var isPageLoadingHomeTab = false
    @State private var isPageLoadingGlassTab = false
    @State private var isPageLoadingWishlistTab = false
    @State private var isPageLoadingBagTab = false
    
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
                                    AnalyticsService.shared.menuTap()
                                } label: {
                                    Image(Images.menuButtonIcon)
                                        .renderingMode(.template)
                                }
                                .padding(.leading)
                            }
                            
                            Spacer()
                            
                            if isPageLoadingHomeTab {
                                ProgressView()
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                .padding(.bottom, 10)
                
                ZStack {
                    homeView
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                showingAR = true
                                AnalyticsService.shared.tryOnTap()
                            } label: {
                                GressoStyiledButton(
                                    image: Images.stars,
                                    text: Localizable.tryOn()
                                )
                            }
                        }
                        .frame(height: doGlassesHaveModelHomeTab ? 60 : 0)
                        .opacity(doGlassesHaveModelHomeTab ? 1 : 0)
                        .allowsHitTesting(doGlassesHaveModelHomeTab)
                        .background(Color.black)
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
                            
                            if isPageLoadingGlassTab {
                                ProgressView()
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                .padding(.bottom, 10)
                
                ZStack {
                    glassView
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                showingAR = true
                                AnalyticsService.shared.tryOnTap()
                            } label: {
                                GressoStyiledButton(
                                    image: Images.stars,
                                    text: Localizable.tryOn()
                                )
                            }
                        }
                        .frame(height: doGlassesHaveModelGlassTab ? 60 : 0)
                        .opacity(doGlassesHaveModelGlassTab ? 1 : 0)
                        .allowsHitTesting(doGlassesHaveModelGlassTab)
                        .background(Color.black)
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
                            
                            if isPageLoadingWishlistTab {
                                ProgressView()
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                .padding(.bottom, 10)
                
                ZStack {
                    wishlistView
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                showingAR = true
                                AnalyticsService.shared.tryOnTap()
                            } label: {
                                GressoStyiledButton(
                                    image: Images.stars,
                                    text: Localizable.tryOn()
                                )
                            }
                        }
                        .frame(height: doGlassesHaveModelWishlistTab ? 60 : 0)
                        .opacity(doGlassesHaveModelWishlistTab ? 1 : 0)
                        .allowsHitTesting(doGlassesHaveModelWishlistTab)
                        .background(Color.black)
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
                            
                            if isPageLoadingBagTab {
                                ProgressView()
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                .frame(height: LocalConstants.navBarHeight)
                .padding(.bottom, 10)
                
                ZStack {
                    bagView
                        .onAppear {
                            bagModel.reload()
                        }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button {
                                showingAR = true
                                AnalyticsService.shared.tryOnTap()
                            } label: {
                                GressoStyiledButton(
                                    image: Images.stars,
                                    text: Localizable.tryOn()
                                )
                            }
                        }
                        .frame(height: doGlassesHaveModelBagTab ? 60 : 0)
                        .opacity(doGlassesHaveModelBagTab ? 1 : 0)
                        .allowsHitTesting(doGlassesHaveModelBagTab)
                        .background(Color.black)
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
                .replacingOccurrences(of: "-1", with: "")
                .uppercased() ?? ""
            
            ARFittingRoomView(
                loadingModels: $loadingModels,
                modelLink: modelLink,
                modelName: name
            )
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: homeModel.urlChanges) { url in
            isPageLoadingHomeTab = true
            loadGlasses(url: url) { have in
                doGlassesHaveModelHomeTab = have
                isPageLoadingHomeTab = false
            }
        }
        .onChange(of: glassModel.urlChanges) { url in
            isPageLoadingGlassTab = true
            loadGlasses(url: url) { have in
                doGlassesHaveModelGlassTab = have
                isPageLoadingGlassTab = false
            }
        }
        .onChange(of: wishlistModel.urlChanges) { url in
            isPageLoadingWishlistTab = true
            loadGlasses(url: url) { have in
                doGlassesHaveModelWishlistTab = have
                isPageLoadingWishlistTab = false
            }
        }
        .onChange(of: bagModel.urlChanges) { url in
            isPageLoadingBagTab = true
            loadGlasses(url: url) { have in
                doGlassesHaveModelBagTab = have
                isPageLoadingBagTab = false
            }
        }
    }
    
    private func loadGlasses(url: URL?, completion: @escaping (Bool) -> Void) {
        guard let url, isARFaceTrackingConfigurationSupported else { return }
        
        let folderName: String
        if url.lastPathComponent.contains("-titanium") {
            folderName = url.lastPathComponent
                .replacingOccurrences(of: "-titanium", with: "First")
                .replacingOccurrences(of: "First-1", with: "Second")
        } else {
            if url.lastPathComponent.contains("-1") {
                folderName = url.lastPathComponent
                    .replacingOccurrences(of: "-1", with: "Second")
            } else {
                folderName = url.lastPathComponent + "First"
            }
        }
        guard folderName != "ar" else { return }
        
        s3Service.filesCount(folderName: folderName) { count in
            loadingModels = []
            for index in 0..<count {
                let model = LoadingModel(id: index, url: nil, isLoading: true)
                loadingModels.append(model)
            }
            modelsCount = count
            if count != .zero {
                s3Service.downloadFilesInFolder(folderName: folderName) { url, image in
                    guard let index = loadingModels.firstIndex(where: { $0.isLoading }) else { return }
                    loadingModels[index].url = url
                    loadingModels[index].isLoading = false
                    loadingModels[index].colorImage = image
                }
                withAnimation {
                    completion(true)
                }
            } else {
                withAnimation {
                    completion(false)
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
