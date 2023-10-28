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

final class WebViewModel: NSObject, ObservableObject, WKScriptMessageHandler {
    
    @Published var canGoBack: Bool = false
    @Published var urlChanges: URL? = nil
    
    var webView: BaseWebView
    
    var reloadWishlistCompletion: (() -> Void)?
    
    init(urlString: String) {
        webView = BaseWebView(frame: .zero)
        super.init()
        
        let contentController = WKUserContentController()
        let userScript = WKUserScript(
            source: "document.getElementsByClassName('shopify-block shopify-app-block')[0].addEventListener('click', function(){ window.webkit.messageHandlers.buttonClicked.postMessage('Button clicked') });",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.add(self, name: "buttonClicked")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = BaseWebView(frame: .zero, configuration: config)
        
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
        
        setupBindings()
    }
    
    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
        
        webView.publisher(for: \.url)
            .assign(to: &$urlChanges)
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func openMenu() {
        webView.openMenu()
    }
    
    @MainActor
    func reload() {
        webView.reload()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "buttonClicked" {
            reloadWishlistCompletion?()
        }
    }
}

final class BaseWebView: WKWebView, UIScrollViewDelegate {
        
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        allowsBackForwardNavigationGestures = true
        customUserAgent = "Gresso"
        addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let estimatedProgress = Float(estimatedProgress)
            guard estimatedProgress >= 0.1 else { return }
            removeHeaderFooter()
        }
    }
    
    private func removeHeaderFooter() {
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
    
    private func removeChat() {
//        It works!
//        var child = document.getElementsByClassName('globalClass_e830')[0];
//        child.parentNode.removeChild(child);
        let script =
        """
            var child = document.getElementsByClassName('globalClass_e830')[0];
            child.parentNode.removeChild(child);
        """
        evaluateJavaScript(script) { (response, error) -> Void in
            if let error {
                print("### error removeChat", error.localizedDescription)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x != 0){
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
        }
    }
}
