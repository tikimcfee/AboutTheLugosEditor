import Foundation
import SwiftUI

struct EditorScrollShareTextView: NSViewRepresentable {
    typealias NSViewType = NSScrollView
    typealias Coordinator = TextCoordinator
    
    @Binding var text: String
    @Binding var previewScrollPosition: ScrollState
    @Binding var editorScrollPosition: ScrollState
    
    func makeCoordinator() -> Coordinator {
        TextCoordinator(view: self,
                        editor: $editorScrollPosition,
                        preview: $previewScrollPosition)
    }
    
    func makeNSView(context: Context) -> NSViewType {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        context.coordinator.configure(textView)
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }
        
        if(!previewScrollPosition.skipConsume) {
            let offset = ceil(textView.bounds.height * previewScrollPosition.percent)
            textView.scroll(.init(x: 0, y: offset))
        }
        
        guard textView.string != text else { return }
        textView.string = text
    }
    
    static func dismantleNSView(_ nsView: NSScrollView, coordinator: TextCoordinator) {
        coordinator.stop()
    }
}

class TextCoordinator: NSObject, NSTextViewDelegate {
    var editorScrollPosition: Binding<ScrollState>
    var previewScrollPosition: Binding<ScrollState>
    let view: EditorScrollShareTextView

    weak private var watching: NSTextView?
    
    init(view: EditorScrollShareTextView,
         editor: Binding<ScrollState>,
         preview: Binding<ScrollState>) {
        self.view = view
        self.editorScrollPosition = editor
        self.previewScrollPosition = preview
        super.init()
    }
    
    func stop() {
        watching?.delegate = nil
        watching = nil
    }
    
    func configure(_ textView: NSTextView) {
        textView.font = NSFont(name: "Menlo", size: 12)
        textView.postsFrameChangedNotifications = true
        textView.isSelectable = true
        textView.isEditable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.drawsBackground = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(boundsChanged),
            name: NSView.boundsDidChangeNotification,
            object: nil
        )
        
        watching = textView
        watching?.delegate = self
    }
    
    @objc func boundsChanged(_ notifiction: NSNotification) {
        guard let textView = watching else { return }
        let center = textView.visibleRect.origin
        let height = textView.bounds.height
        DispatchQueue.main.async {
            self.previewScrollPosition.skipConsume.wrappedValue = true
            self.editorScrollPosition.skipConsume.wrappedValue = false
            self.editorScrollPosition.scroll.wrappedValue = center.y
            self.editorScrollPosition.height.wrappedValue = height
        }
        
    }
    
    func textDidChange(_ notification: Notification) {
        guard let text = watching?.string else {
            return
        }
        view.text = text
    }
}
