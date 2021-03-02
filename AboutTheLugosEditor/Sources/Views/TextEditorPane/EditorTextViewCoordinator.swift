import SwiftUI
import Foundation

class TextCoordinator: NSObject, NSTextViewDelegate {
    var editorScrollPosition: Binding<ScrollState>
    var previewScrollPosition: Binding<ScrollState>
    var text: Binding<String>
    
    public lazy var wrappingScrollView: NSScrollView = NSTextView.scrollableTextView()
    public lazy var textView: NSTextView = createTextView()
    
    init(text: Binding<String>,
         editor: Binding<ScrollState>,
         preview: Binding<ScrollState>) {
        self.text = text
        self.editorScrollPosition = editor
        self.previewScrollPosition = preview
        super.init()
    }
    
    deinit {
        textView.delegate = nil
    }
    
    
    @objc func boundsChanged(_ notifiction: NSNotification) {
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
        text.wrappedValue = textView.string
    }
    
}

private extension TextCoordinator {
    func createTextView() -> NSTextView {
        let textView = wrappingScrollView.documentView as! NSTextView
        
        textView.font = NSFont(name: "Menlo", size: 12)
        textView.postsFrameChangedNotifications = true
        textView.isSelectable = true
        textView.isEditable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.drawsBackground = false
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.isAutomaticTextCompletionEnabled = true
        textView.isContinuousSpellCheckingEnabled = true
        textView.isIncrementalSearchingEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        
        textView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(boundsChanged),
            name: NSView.boundsDidChangeNotification,
            object: nil
        )
        
        return textView
    }
}
