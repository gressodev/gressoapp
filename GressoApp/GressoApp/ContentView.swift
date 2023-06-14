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
    
    @State private var activeTab: ActiveTab = .glass
    
    @StateObject var homeModel = WebViewModel(urlString: "https://gresso.com")
    @StateObject var glassModel = WebViewModel(urlString: "https://gresso.com/pages/ar")
    @StateObject var bagModel = WebViewModel(urlString: "https://gresso.com/cart")
    
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
