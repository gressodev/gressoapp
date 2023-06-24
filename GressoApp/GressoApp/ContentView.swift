//
//  ContentView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 07.06.2023.
//

import SwiftUI

enum ActiveTab: Int {
    case home = 0
    case glass = 1
    case bag = 2
}

struct ContentView : View {
    
    private enum LocalConstants {
        static let navBarHeight: CGFloat = 50
        
        enum VirtualTryOnButton {
            static let height: CGFloat = 40
            static let cornerRadius: CGFloat = 20
            static let bottomPadding: CGFloat = 80
            static let backgroundOpacity: Double = 0.1
        }
    }
    
    @State private var destinations: [URL] = []
    
    @State private var showingAR = false
    
    @StateObject private var s3Service = S3ServiceHandler()
    
    @State private var activeTab: ActiveTab = .glass
    
    @StateObject var homeModel = WebViewModel(urlString: "https://gresso.com")
    @StateObject var glassModel = WebViewModel(urlString: "https://gresso.com/pages/ar")
    @StateObject var bagModel = WebViewModel(urlString: "https://gresso.com/cart")
    
    @State private var doGlassesHaveModelHomeTab = false
    @State private var doGlassesHaveModelGlassTab = false
    @State private var doGlassesHaveModelBagTab = false
    @State private var isModelLoading = false
    
    var body: some View {
        let homeView = WebView(webView: homeModel.webView)
        let glassView = WebView(webView: glassModel.webView)
        let bagView = WebView(webView: bagModel.webView)
        
        TabView(selection: $activeTab) {
            ZStack {
                VStack {
                    HStack {
                        Button {
                            homeModel.openMenu()
                        } label: {
                            Image(Assets.Images.menuButtonIcon)
                                .renderingMode(.template)
                        }
                        .padding()
                        
                        if homeModel.canGoBack {
                            Button {
                                homeModel.goBack()
                            } label: {
                                Image(systemName: Assets.Images.chevronBackward)
                                    .renderingMode(.template)
                            }
                            .padding()
                        }
                        
                        Spacer()
                        
                        if isModelLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .frame(height: LocalConstants.navBarHeight)
                    
                    homeView
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        if doGlassesHaveModelHomeTab {
                            Button {
                                showingAR = true
                            } label: {
                                Image(Assets.Images.virtualTryOnIcon)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: LocalConstants.VirtualTryOnButton.height)
                            }
                            .background(.black.opacity(LocalConstants.VirtualTryOnButton.backgroundOpacity))
                            .cornerRadius(LocalConstants.VirtualTryOnButton.cornerRadius)
                            .padding(.bottom, LocalConstants.VirtualTryOnButton.bottomPadding)
                        }
                        Spacer()
                    }
                }
            }
            .tabItem {
                Image(Assets.Images.TabBar.tabItemHome)
                    .renderingMode(.template)
            }
            .tag(ActiveTab.home)
            
            ZStack {
                VStack {
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
                        
                        if isModelLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .frame(height: LocalConstants.navBarHeight)
                    
                    glassView
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        if doGlassesHaveModelGlassTab {
                            Button {
                                showingAR = true
                            } label: {
                                Image(Assets.Images.virtualTryOnIcon)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: LocalConstants.VirtualTryOnButton.height)
                            }
                            .background(.black.opacity(LocalConstants.VirtualTryOnButton.backgroundOpacity))
                            .cornerRadius(LocalConstants.VirtualTryOnButton.cornerRadius)
                            .padding(.bottom, LocalConstants.VirtualTryOnButton.bottomPadding)
                        }
                        Spacer()
                    }
                }
            }
            .tabItem {
                Image(Assets.Images.TabBar.tabItemGlasses)
                    .renderingMode(.template)
            }
            .tag(ActiveTab.glass)
            
            ZStack {
                VStack {
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
                        
                        if isModelLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .frame(height: LocalConstants.navBarHeight)
                    
                    bagView
                        .onAppear {
                            bagModel.reload()
                        }
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        if doGlassesHaveModelBagTab {
                            Button {
                                showingAR = true
                            } label: {
                                Image(Assets.Images.virtualTryOnIcon)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: LocalConstants.VirtualTryOnButton.height)
                            }
                            .background(.black.opacity(LocalConstants.VirtualTryOnButton.backgroundOpacity))
                            .cornerRadius(LocalConstants.VirtualTryOnButton.cornerRadius)
                            .padding(.bottom, LocalConstants.VirtualTryOnButton.bottomPadding)
                        }
                        Spacer()
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
        .sheet(isPresented: $showingAR) {
            if !destinations.isEmpty {
                ARFittingRoomView(destinations: destinations)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onChange(of: homeModel.urlChanges) { url in
            guard let url else { return }
            isModelLoading = true
            
            s3Service.downloadFilesInFolder(folderName: url.lastPathComponent) { urls in
                if !urls.isEmpty {
                    destinations = urls
                    withAnimation {
                        doGlassesHaveModelHomeTab = true
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModelHomeTab = false
                    }
                }
                isModelLoading = false
            }
        }
        .onChange(of: glassModel.urlChanges) { url in
            guard let url else { return }
            isModelLoading = true
            
            s3Service.downloadFilesInFolder(folderName: url.lastPathComponent) { urls in
                if !urls.isEmpty {
                    destinations = urls
                    withAnimation {
                        doGlassesHaveModelGlassTab = true
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModelGlassTab = false
                    }
                }
                isModelLoading = false
            }
        }
        .onChange(of: bagModel.urlChanges) { url in
            guard let url else { return }
            isModelLoading = true
            
            s3Service.downloadFilesInFolder(folderName: url.lastPathComponent) { urls in
                if !urls.isEmpty {
                    destinations = urls
                    withAnimation {
                        doGlassesHaveModelBagTab = true
                    }
                } else {
                    withAnimation {
                        doGlassesHaveModelBagTab = false
                    }
                }
                isModelLoading = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
