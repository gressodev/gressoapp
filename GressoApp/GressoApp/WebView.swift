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
    typealias UIViewType = BaseWebView

    let webView: BaseWebView
    
    func makeUIView(context: Context) -> BaseWebView {
        webView
    }
    
    func updateUIView(_ uiView: BaseWebView, context: Context) { }
}

final class WebViewModel: ObservableObject {
    
    @Published var canGoBack: Bool = false
    
    let webView: BaseWebView
    
    init(urlString: String) {
        webView = BaseWebView(frame: .zero)
        
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
        
        setupBindings()
    }
    
    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func openMenu() {
        webView.openMenu()
    }
    
    func reload() {
        webView.reload()
    }
}

final class BaseWebView: WKWebView {
        
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        allowsBackForwardNavigationGestures = true
        customUserAgent = "Gresso"
        addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let estimatedProgress = Float(estimatedProgress)
            guard estimatedProgress >= 0.1 else { return }
            removeHeaderFooter()
        }
        if keyPath == #keyPath(WKWebView.canGoBack) {
            print("###", canGoBack)
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
