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
            VStack {
                HStack {
                    Button {
                        homeModel.openMenu()
                    } label: {
                        Image("menuButtonIcon")
                            .renderingMode(.template)
                    }
                    .padding()
                    
                    if homeModel.canGoBack {
                        Button {
                            homeModel.goBack()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .renderingMode(.template)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    if doGlassesHaveModelHomeTab {
                        Button {
                            showingAR = true
                        } label: {
                            Image("virtualTryOnIcon")
                                .renderingMode(.template)
                                .frame(maxHeight: 16)
                        }
                        .padding()
                    } else if isModelLoading {
                        ProgressView()
                            .padding()
                    }
                }
                homeView
            }
            .tabItem {
                Image("tabItem.home")
                    .renderingMode(.template)
            }
            .tag(ActiveTab.home)
            
            VStack {
                HStack {
                    Button {
                        glassModel.goBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .renderingMode(.template)
                    }
                    .padding()
                    .disabled(!glassModel.canGoBack)
                    
                    Spacer()
                    
                    if doGlassesHaveModelGlassTab {
                        Button {
                            showingAR = true
                        } label: {
                            Image("virtualTryOnIcon")
                                .renderingMode(.template)
                                .frame(maxHeight: 16)
                        }
                        .padding()
                    } else if isModelLoading {
                        ProgressView()
                            .padding()
                    }
                }
                glassView
            }
            .tabItem {
                Image("tabItem.glasses")
                    .renderingMode(.template)
            }
            .tag(ActiveTab.glass)
            
            VStack {
                HStack {
                    Button {
                        bagModel.goBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .renderingMode(.template)
                    }
                    .padding()
                    .disabled(!bagModel.canGoBack)
                    
                    Spacer()
                    
                    if doGlassesHaveModelBagTab {
                        Button {
                            showingAR = true
                        } label: {
                            Image("virtualTryOnIcon")
                                .renderingMode(.template)
                                .frame(maxHeight: 16)
                        }
                        .padding()
                    } else if isModelLoading {
                        ProgressView()
                            .padding()
                    }
                }
                bagView
                    .onAppear {
                        bagModel.reload()
                    }
            }
            .tabItem {
                VStack {
                    Image("tabItem.bag")
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
                    doGlassesHaveModelHomeTab = true
                } else {
                    doGlassesHaveModelHomeTab = false
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
                    doGlassesHaveModelGlassTab = true
                } else {
                    doGlassesHaveModelGlassTab = false
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
                    doGlassesHaveModelBagTab = true
                } else {
                    doGlassesHaveModelBagTab = false
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
