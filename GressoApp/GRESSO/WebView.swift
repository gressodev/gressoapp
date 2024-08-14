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
    @Published var cartBadgeValueChanges: Int = 0
    @Published var wishlistBadgeValueChanges: Int = 0
    
    var webView: WKWebView
    
    var reloadWishlistCompletion: (() -> Void)?
    var reloadCartCompletion: (() -> Void)?
    var hideTryOnButtonCompletion: (() -> Void)?
    var showTryOnButtonCompletion: (() -> Void)?
    
    private var minusOneInWishlist = false
    
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
        
        let prescriptionLensesScript = WKUserScript(
            source: """
            window.addEventListener("load", (event) => {
            setTimeout(function() {
            document.getElementsByClassName('la-select-lenses-btn')[0].addEventListener('click', function(){ window.webkit.messageHandlers.prescriptionLensesScript.postMessage('Button clicked')
            });
            },1000);
            });
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(prescriptionLensesScript)
        contentController.add(self, name: "prescriptionLensesScript")
        
        let closePrescriptionLensesScript = WKUserScript(
            source: """
            document.addEventListener("LensAdvizor:selectLensModal:close", function() {
                window.webkit.messageHandlers.closePrescriptionLensesScript.postMessage('Button clicked')
            });
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(closePrescriptionLensesScript)
        contentController.add(self, name: "closePrescriptionLensesScript")
        
        let addToCartScript = WKUserScript(
            source: """
            document.getElementsByClassName('product-form__add-button button button--primary button--full')[0].addEventListener('click', function(){ window.webkit.messageHandlers.addToCartScript.postMessage('Button clicked');
            });
            document.getElementsByClassName('la-prescription-form-btn la-translate')[0].addEventListener('click', function(){ window.webkit.messageHandlers.addToCartScript.postMessage('Button clicked');
            });
            document.getElementsByClassName('wishlist-cart wishlist-move-cart')[0].addEventListener('click', function(){ window.webkit.messageHandlers.addToCartScript.postMessage('Button clicked');
            });
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(addToCartScript)
        contentController.add(self, name: "addToCartScript")
        
        let deleteFromWishlistScript = WKUserScript(
            source: """
            window.addEventListener("load", (event) => {
            setTimeout(function() {
            let elements = document.getElementsByClassName('wh-wishlist-remove wishlist_page_remove_product');
            for (let i = 0; i < elements.length; i++) {
                elements[i].addEventListener('click', function(){ window.webkit.messageHandlers.deleteFromWishlistScript.postMessage('Button clicked')});
            };
            },1000);
            });
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(deleteFromWishlistScript)
        contentController.add(self, name: "deleteFromWishlistScript")
        
        let addToCartFromWishlistScript = WKUserScript(
            source: """
            window.addEventListener("load", (event) => {
            setTimeout(function() {
            let elements = document.getElementsByClassName('wishlist-cart wishlist-move-cart');
            for (let i = 0; i < elements.length; i++) {
                elements[i].addEventListener('click', function(){ window.webkit.messageHandlers.addToCartFromWishlistScript.postMessage('Button clicked')});
            };
            },1000);
            });
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(addToCartFromWishlistScript)
        contentController.add(self, name: "addToCartFromWishlistScript")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: config)
        
        webView.allowsBackForwardNavigationGestures = true
//        webView.customUserAgent = "Gresso"
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.uiDelegate = self
        
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
        showTryOnButtonCompletion?()
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
        } else if message.name == "prescriptionLensesScript" {
            hideTryOnButtonCompletion?()
        } else if message.name == "closePrescriptionLensesScript" {
            showTryOnButtonCompletion?()
        } else if message.name == "addToCartScript" {
            reloadCartCompletion?()
        } else if message.name == "deleteFromWishlistScript" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reloadCartCompletion?()
                self.minusOneInWishlist = true
            }
        } else if message.name == "addToCartFromWishlistScript" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reloadCartCompletion?()
                self.reloadWishlistBadge()
                self.minusOneInWishlist = true
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let estimatedProgress = Float(webView.estimatedProgress)
            guard estimatedProgress >= 0.1 else { return }
            removeHeaderFooter()
            removeChat()
            disableCookies()
            if let url = webView.url, url.absoluteString.contains("/pages/ar") {
                removeAnnouncementBar()
            }
            
            guard estimatedProgress >= 0.75 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reloadCartBadge()
                self.reloadWishlistBadge()
            }
        }
    }
    
    private func removeHeaderFooter() {
        let script =
            """
            var css = '.header,.footer {display: none !important;}',
                    head = document.head || document.getElementsByTagName('head')[0],
                    style = document.createElement('style');
                    
            style.type = 'text/css';
            style.appendChild(document.createTextNode(css));
            head.appendChild(style);
            """
        webView.evaluateJavaScript("setTimeout(function() {\(script)});") { response, error -> Void in
            if let error {
                print("### error removeHeaderFooter", error.localizedDescription)
            }
        }
    }
    
    private func removeAnnouncementBar() {
        let script =
            """
            var css = '.announcement-bar {display: none !important;}',
                    head = document.head || document.getElementsByTagName('head')[0],
                    style = document.createElement('style');
                    
            style.type = 'text/css';
            style.appendChild(document.createTextNode(css));
            head.appendChild(style);
            """
        webView.evaluateJavaScript("setTimeout(function() {\(script)});") { response, error -> Void in
            if let error {
                print("### error removeAnnouncementBar", error.localizedDescription)
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
    
    private func reloadCartBadge() {
        webView.evaluateJavaScript("""
            document.getElementsByClassName('header__cart-count header__cart-count--floating bubble-count')[0].innerText
        """) { [weak self] (result, error) in
            guard let self else { return }
            if let error {
                print("###", error)
                return
            } else {
                let stringValue = "\(result ?? "")"
                guard let intValue = Int(stringValue) else { return }
                cartBadgeValueChanges = intValue
            }
        }
    }
    
    private func reloadWishlistBadge() {
        webView.evaluateJavaScript("""
            document.getElementsByClassName('wishlist-h-count wishlist-total-count')[0].innerText
        """) { [weak self] (result, error) in
            guard let self else { return }
            if let error {
                print("###", error)
                return
            } else {
                let stringValue = "\(result ?? "")"
                guard let intValue = Int(stringValue) else { return }
                wishlistBadgeValueChanges = minusOneInWishlist ? intValue - 1 : intValue
                minusOneInWishlist = false
            }
        }
    }
}

extension WebViewModel: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            completionHandler()
        }))
        
        if var topController = UIApplication.topViewController() {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            topController.present(alertController, animated: true)
        }
        
    }
}
