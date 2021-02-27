import WebKit
import SwiftUI

class WebViewCoordinator {
    
}

struct PreviewView: NSViewRepresentable {
    typealias Coordinator = WebViewCoordinator
    typealias NSViewType = WKWebView
    
    var evaluableJavascript: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
//        // Add a `body` dom object to target with `document.body.innertHTML`
//        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
//        webView.evaluateJavaScript(evaluableJavascript) { _, error in
//            if let error = error {
//                print(error)
//            }
//        }
        
        webView.loadHTMLString(evaluableJavascript, baseURL: nil)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }
    
}

