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
        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Setting the dom body may take time, so just call async
        webView.callAsyncJavaScript(
            evaluableJavascript,
            in: nil,
            in: WKContentWorld.defaultClient
        )
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }
    
}

