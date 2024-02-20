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
    
    private enum LocalConstants {
        static let gressoUrl = (Locale.current.regionCode ?? "") == "RU" ? "gresso.ru" : "gresso.com"
    }

    var url: URL {
        switch self {
        case .home:
            return URL(string: "https://\(LocalConstants.gressoUrl)")!
        case .glass:
            return URL(string: "https://\(LocalConstants.gressoUrl)/pages/ar")!
        case .wishlist:
            return URL(string: "https://\(LocalConstants.gressoUrl)/apps/wishlist")!
        case .bag:
            return URL(string: "https://\(LocalConstants.gressoUrl)/cart")!
        }
    }
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
    
    @StateObject var webModel = WebViewModel(
        urlString: "https://\(LocalConstants.gressoUrl)/pages/ar"
    )
    
    @State private var doGlassesHaveModel = false
    @State private var isPageLoading = false
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .white
    }
    
    var body: some View {
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
                        if activeTab == .home {
                            Button {
                                webModel.openMenu()
                                AnalyticsService.shared.menuTap()
                            } label: {
                                Image(Images.menuButtonIcon)
                                    .renderingMode(.template)
                            }
                            .padding(.leading)
                        } else if webModel.canGoBack {
                            Button {
                                webModel.goBack()
                            } label: {
                                Image(systemName: Images.chevronBackward)
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
            .padding(.bottom, 10)
            
            ZStack {
                WebView(webView: webModel.webView)
                
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
                    .frame(height: doGlassesHaveModel ? 60 : 0)
                    .opacity(doGlassesHaveModel ? 1 : 0)
                    .allowsHitTesting(doGlassesHaveModel)
                    .background(Color.black)
                }
            }
            TabView(selection: $activeTab) {
                VStack {}
                    .frame(maxHeight: 38)
                    .tabItem {
                        let image = activeTab == .home ? Image(uiImage: Images.homeActive) : Image(uiImage: Images.home)
                        image
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 24, height: 24)
                            .padding(.top, 14)
                    }
                    .tag(ActiveTab.home)
                
                VStack {}
                    .frame(maxHeight: 38)
                    .tabItem {
                        let image = activeTab == .glass ? Image(uiImage: Images.squaresActive) : Image(uiImage: Images.squares)
                        image
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 24, height: 24)
                            .padding(.top, 14)
                    }
                    .tag(ActiveTab.glass)
                
                VStack {}
                    .frame(maxHeight: 38)
                    .tabItem {
                        let image = activeTab == .wishlist ? Image(uiImage: Images.favoritesActive) : Image(uiImage: Images.favorites)
                        image
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 24, height: 24)
                            .padding(.top, 14)
                    }
                    .tag(ActiveTab.wishlist)
                
                VStack {}
                    .frame(maxHeight: 38)
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
            .frame(maxHeight: 38)
        }
        .preferredColorScheme(ColorScheme.dark)
        .tint(.white)
        .fullScreenCover(isPresented: $showingAR) {
            let modelLink: URL? = webModel.urlChanges
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
        .onChange(of: webModel.urlChanges) { url in
            isPageLoading = true
            loadGlasses(url: url) { have in
                doGlassesHaveModel = have
                isPageLoading = false
            }
        }
        .onChange(of: activeTab) { tab in
            webModel.load(url: tab.url)
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
