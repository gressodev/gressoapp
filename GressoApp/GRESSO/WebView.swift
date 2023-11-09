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
    typealias UIViewType = WKWebView

    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

final class WebViewModel: NSObject, ObservableObject, WKScriptMessageHandler, UIScrollViewDelegate {
    
    @Published var canGoBack: Bool = false
    @Published var urlChanges: URL? = nil
    
    var webView: WKWebView
    
    var reloadWishlistCompletion: (() -> Void)?
    
    init(urlString: String) {
        webView = WKWebView(frame: .zero)
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
        
        webView = WKWebView(frame: .zero, configuration: config)
        
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "Gresso"
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
        
        setupBindings()
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
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
        webView.evaluateJavaScript(
            "document.getElementsByClassName('header__icon-wrapper tap-area hidden-desk')[0].click();"
        ) { (key, err) in }
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let estimatedProgress = Float(webView.estimatedProgress)
            guard estimatedProgress >= 0.1 else { return }
            removeHeaderFooter()
            removeChat()
            disableCookies()
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
        webView.evaluateJavaScript("setTimeout(function() {\(script)});"){ (response, error) -> Void in
            if let error {
                print("### error removeHeaderFooter", error.localizedDescription)
            }
        }
    }
    
    private func disableCookies() {
        webView.evaluateJavaScript("window.disableCookies = true;") { (response, error) -> Void in }
    }
    
    private func removeChat() {
        let script =
        """
            window.jivo_onLoadCallback = function (){
                window.jivo_destroy();
            }
        """
        webView.evaluateJavaScript(script) { (response, error) -> Void in }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x != 0){
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
        }
    }
}
