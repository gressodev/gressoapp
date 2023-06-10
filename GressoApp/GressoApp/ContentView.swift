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
    
    var body: some View {
        let homeView = WebView(selectedTab: .home)
        let glassView = WebView(selectedTab: .glass)
        let bagView = WebView(selectedTab: .bag)
        
        TabView(selection: $activeTab) {
            VStack {
                HStack {
                    Button {
                        homeView.openMenu()
                    } label: {
                        Image("menuButtonIcon")
                            .renderingMode(.template)
                    }
                    .padding()
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
                        glassView.openMenu()
                    } label: {
                        Image("menuButtonIcon")
                            .renderingMode(.template)
                    }
                    .padding()
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
                        bagView.openMenu()
                    } label: {
                        Image("menuButtonIcon")
                            .renderingMode(.template)
                    }
                    .padding()
                    Spacer()
                }
                bagView
                    .onAppear {
                        bagView.reload()
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
