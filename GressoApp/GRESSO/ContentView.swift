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
    
    var url: URL {
        switch self {
        case .home:
            return URL(string: "https://gresso.com/")!
        case .glass:
            return URL(string: "https://gresso.com/pages/ar/")!
        case .wishlist:
            return URL(string: "https://gresso.com/apps/wishlist/")!
        case .bag:
            return URL(string: "https://gresso.com/cart/")!
        }
    }
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
    
    @StateObject var webViewModel = WebViewModel(urlString: "https://gresso.com/pages/ar")
    
    @State private var doGlassesHaveModel = false
    @State private var isPageLoading = false
    @State private var showMenuButton = false
    
    var body: some View {
        let webView = WebView(webView: webViewModel.webView)
        
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Text("GRESSO")
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                }
                
                HStack {
                    if showMenuButton {
                        Button {
                            webViewModel.openMenu()
                        } label: {
                            Image(Assets.Images.menuButtonIcon)
                                .renderingMode(.template)
                        }
                        .padding()
                    } else {
                        Button {
                            webViewModel.goBack()
                        } label: {
                            Image(systemName: Assets.Images.chevronBackward)
                                .renderingMode(.template)
                        }
                        .disabled(!webViewModel.canGoBack)
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
            
            webView
            
            if doGlassesHaveModel {
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
            HStack {
                Spacer()
                Button {
                    activeTab = .home
                    webViewModel.loadUrl(activeTab.url)
                } label: {
                    Image(Assets.Images.TabBar.tabItemHome)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(activeTab == .home ? .accentColor : .gray)
                }
                Spacer()
                Button {
                    activeTab = .glass
                    webViewModel.loadUrl(activeTab.url)
                } label: {
                    Image(Assets.Images.menuButtonIcon)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(activeTab == .glass ? .accentColor : .gray)
                }
                Spacer()
                Button {
                    activeTab = .wishlist
                    webViewModel.loadUrl(activeTab.url)
                } label: {
                    Image(systemName: Assets.Images.heart)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(activeTab == .wishlist ? .accentColor : .gray)
                }
                Spacer()
                Button {
                    activeTab = .bag
                    webViewModel.loadUrl(activeTab.url)
                } label: {
                    Image(Assets.Images.TabBar.tabItemBag)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(activeTab == .bag ? .accentColor : .gray)
                }
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showingAR) {
            ARFittingRoomView(
                loadingModels: $loadingModels,
                modelLink: webViewModel.urlChanges
            )
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: webViewModel.urlChanges) { url in
            if url == ActiveTab.home.url {
                activeTab = .home
            }
            if url == ActiveTab.glass.url {
                activeTab = .glass
            }
            if url == ActiveTab.wishlist.url {
                activeTab = .wishlist
            }
            if url == ActiveTab.bag.url {
                activeTab = .bag
            }
            showMenuButton = activeTab == .home && activeTab.url == url
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
                        doGlassesHaveModel = true
                        isPageLoading = false
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModel = false
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
