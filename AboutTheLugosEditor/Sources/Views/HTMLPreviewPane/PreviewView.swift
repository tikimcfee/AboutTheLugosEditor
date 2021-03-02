import WebKit
import SwiftUI

struct PreviewView: NSViewRepresentable {
    typealias Coordinator = WebViewCoordinator
    typealias NSViewType = WKWebView
    
    @Binding var previewScrollState: ScrollState
    @Binding var editorScrollState: ScrollState
    var evaluableJavascript: String
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(editor: $editorScrollState,
                           preview: $previewScrollState)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        context.coordinator.setup(webView)
        
        // Add a `body` dom object to target with `document.body.innertHTML`
        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
        
        return webView
    }
    
    private var setScrollScript: String {
"""
window.scrollTo(0, parseInt(document.documentElement.scrollHeight * \(editorScrollState.percent)));
"""
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Setting the dom body may take time, so just call async
        webView.callAsyncJavaScript(
            evaluableJavascript,
            in: nil,
            in: WKContentWorld.defaultClient
        )
        
        if !editorScrollState.skipConsume {
            webView.callAsyncJavaScript(
                setScrollScript,
                in: nil,
                in: WKContentWorld.defaultClient
            )
        }
    }
}

