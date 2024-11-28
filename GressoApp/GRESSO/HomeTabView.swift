//
//  HomeTabView.swift
//  GRESSO
//
//  Created by Dmitrii on 24.11.2024.
//

import SwiftUI

struct HomeTabView: View {
    @State private var homeModel: WebViewModel
    @State private var doGlassesHaveModelHomeTab: Bool
    @State private var isPageLoadingHomeTab: Bool
    @State private var showingAR: Bool
    private let gressoLabel: String
    private let navBarHeight: CGFloat
    
    var body: some View {
        let homeView = WebView(webView: homeModel.webView)

        VStack {
            VStack {
                Spacer()
                ZStack {
                    HStack {
                        Spacer()
                        Text(gressoLabel)
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
            .frame(height: navBarHeight)
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
    }
}
