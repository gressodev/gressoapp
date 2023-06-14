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
    
    @State private var destination: URL?
    
    @State private var showingAR = false
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var activeTab: ActiveTab = .glass
    
    @StateObject var homeModel = WebViewModel(urlString: "https://gresso.com")
    @StateObject var glassModel = WebViewModel(urlString: "https://gresso.com/pages/ar")
    @StateObject var bagModel = WebViewModel(urlString: "https://gresso.com/cart")
    
    @State private var doGlassesHaveModel = false
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
                    
                    if doGlassesHaveModel {
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
            if let destination {
                ARViewContainer(destination: destination)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onChange(of: homeModel.urlChanges) { url in
            guard let url else { return }
            
            var query: String
            if #available(iOS 16.0, *) {
                query = url.query() ?? ""
            } else {
                query = url.query ?? ""
            }
            isModelLoading = true
            viewModel.downloadGlasses(with: url.lastPathComponent, query, completion: { url in
                DispatchQueue.main.async {
                    if let url {
                        destination = url
                        doGlassesHaveModel = true
                    } else {
                        doGlassesHaveModel = false
                    }
                    isModelLoading = false
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import Factory

final class ViewModel: ObservableObject {
    
    @Injected(\.loadGlassesService) private var loadGlassesService
    
    func downloadGlasses(with modelName: String, _ colorName: String, completion: @escaping (URL?) -> Void) {
        loadGlassesService.loadModel(with: modelName, colorName, completion: completion)
//        loadGlassesService.loadModels(with: modelName, completion: completion)
    }
    
}
