import SwiftUI
import Foundation
import WebKit

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

