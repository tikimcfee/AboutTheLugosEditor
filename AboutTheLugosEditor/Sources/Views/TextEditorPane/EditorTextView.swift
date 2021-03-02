import Foundation
import SwiftUI

struct EditorScrollShareTextView: NSViewRepresentable {
    typealias NSViewType = NSScrollView
    typealias Coordinator = TextCoordinator
    
    @Binding var text: String
    @Binding var previewScrollPosition: ScrollState
    @Binding var editorScrollPosition: ScrollState
    
    func makeCoordinator() -> Coordinator {
        TextCoordinator(text: $text,
                        editor: $editorScrollPosition,
                        preview: $previewScrollPosition)
    }
    
    func makeNSView(context: Context) -> NSViewType {
        return context.coordinator.wrappingScrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = context.coordinator.textView
        
        if(!previewScrollPosition.skipConsume) {
            let offset = ceil(textView.bounds.height * previewScrollPosition.percent)
            textView.scroll(.init(x: 0, y: offset))
        }
        
        guard textView.string != text else { return }
        textView.string = text
    }
}
