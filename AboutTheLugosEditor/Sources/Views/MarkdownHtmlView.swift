import WebKit
import SwiftUI

class WebViewCoordinator {
    
}

struct MarkdownHtmlView: NSViewRepresentable {
    typealias Coordinator = WebViewCoordinator
    typealias NSViewType = WKWebView
    
    @Binding var htmlContent: String
    var lastHtmlContent: String?
    
    func makeNSView(context: Context) -> WKWebView {
        let coordinator = context.coordinator
        
        return WKWebView()
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let coordinator = context.coordinator
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }
    
}
