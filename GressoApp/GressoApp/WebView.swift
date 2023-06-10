//
//  WebView.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 10.06.2023.
//

import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
    
    private let urlString: String
    
    init(selectedTab: ActiveTab) {
        switch selectedTab {
        case .home:
            urlString = "https://gresso.com"
        case .glass:
            urlString = "https://gresso.com/pages/ar"
        case .bag:
            urlString = "https://gresso.com/cart"
        }
    }
    
    let baseWebView = BaseWebView()
    
    func makeUIView(context: Context) -> BaseWebView {
        baseWebView
    }
    
    func updateUIView(_ uiView: BaseWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        uiView.load(URLRequest(url: url))
    }
    
    func openMenu() {
        baseWebView.openMenu()
    }
    
    func reload() {
        guard let url = URL(string: urlString) else { return }
        baseWebView.load(URLRequest(url: url))
    }
}

final class BaseWebView: WKWebView, WKNavigationDelegate {
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        customUserAgent = "Gresso"
        
        addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let estimatedProgress = Float(estimatedProgress)
        if keyPath == "estimatedProgress" {
            guard estimatedProgress >= 0.1 else { return }
            removeHeaderFooter()
        }
    }
    
    func removeHeaderFooter() {
        let script =
"""
var css = '.header,.footer,.announcement-bar {display: none !important;}',
        head = document.head || document.getElementsByTagName('head')[0],
            style = document.createElement('style');
        
        style.type = 'text/css';
            style.appendChild(document.createTextNode(css));
        head.appendChild(style);
"""
        evaluateJavaScript("setTimeout(function() {\(script)});"){ (response, error) -> Void in
            if let error {
                print("### error removeHeaderFooter", error.localizedDescription)
            }
        }
    }
    
    func openMenu() {
        evaluateJavaScript("document.getElementsByClassName('header__icon-wrapper tap-area hidden-desk')[0].click();") { (key, err) in
            if let err = err {
                print("### error openMenu", err.localizedDescription)
            }
        }
    }
}
