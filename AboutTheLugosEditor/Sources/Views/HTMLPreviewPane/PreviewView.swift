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

class WebViewCoordinator: NSObject, WKScriptMessageHandler {
    var editorScrollPosition: Binding<ScrollState>
    var previewScrollPosition: Binding<ScrollState>
    
    init(editor: Binding<ScrollState>,
         preview: Binding<ScrollState>) {
        self.editorScrollPosition = editor
        self.previewScrollPosition = preview
        super.init()
    }
    
    func setup(_ webView: WKWebView) {
        let scrollScript = WKUserScript(
            source: scrollCallbackScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        webView.configuration.userContentController
            .addUserScript(scrollScript)
        webView.configuration.userContentController
            .add(self, name: "scrollEvent")
    }
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "scrollEvent",
              let body = message.body as? [String: Any?],
              let newScroll = body["scroll"] as? Int,
              let newHeight = body["height"] as? Int
        else { return }
        DispatchQueue.main.async {
            self.editorScrollPosition.skipConsume.wrappedValue = true
            self.previewScrollPosition.skipConsume.wrappedValue = false
            self.previewScrollPosition.scroll.wrappedValue = CGFloat(newScroll)
            self.previewScrollPosition.height.wrappedValue = CGFloat(newHeight)
        }
    }
    
    private var scrollCallbackScript: String {
"""
function computeAndSend() {
    let height = document.documentElement.scrollHeight;
    let scroll = window.scrollY;

    window.webkit.messageHandlers.scrollEvent.postMessage({
        'scroll': scroll,
        'height': height
    });
}
document.addEventListener('scroll', function(event) {
    computeAndSend()
})
"""
    }
}
