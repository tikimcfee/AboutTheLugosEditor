import SwiftUI
import Combine

struct MainEditorView: View {
    
    @State var size = CGSize()
    @State var previewScrollState = ScrollState()
    @State var editorScrollState = ScrollState()
    
    @EnvironmentObject var editorState: MainEditorState
    @EnvironmentObject var metaState: MetaViewState
    
    // I have absolutely no idea how this works. The window is retained somehow and not recreated?
    // So the onAppear only creates a single window and view, apparently.
    var metaWindowContainer = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 600),
        styleMask: [.titled, .resizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    
    var body: some View {
        HStack {
            ZStack(alignment: .bottomTrailing) {
                EditorScrollShareTextView(
                    text: $editorState.editingBody,
                    previewScrollPosition: $previewScrollState,
                    editorScrollPosition: $editorScrollState
                )
                Button("Save Changes") {
                    editorState.saveArticleChangesRequested()
                }
                .disabled(editorState.saveButtonDisabled)
                .keyboardShortcut("s", modifiers: [.command])
                .padding()
            }
            
            Spacer().frame(width: 8)
            
            PreviewView(
                previewScrollState: $previewScrollState,
                editorScrollState: $editorScrollState,
                evaluableJavascript: editorState.previewJavascript
            )
        }
        .padding()
        .onAppear {
            let dcView = MetaView()
                .environmentObject(editorState)
                .environmentObject(metaState)
            self.metaWindowContainer.contentView = NSHostingView(rootView: dcView)
            self.metaWindowContainer.makeKeyAndOrderFront(nil)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static let test: MainEditorState = {
        let state = MainEditorState(converter: EscapingMarkdownConverter())
        state.selection = .none
        state.editingBody = "# Hello, world!"
        
        return state
    }()
    
    static var previews: some View {
        MainEditorView()
            .previewLayout(/*@START_MENU_TOKEN@*/.fixed(width: /*@START_MENU_TOKEN@*/910.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/768.0/*@END_MENU_TOKEN@*/)/*@END_MENU_TOKEN@*/)
            .environmentObject(test)
            .environmentObject(MetaViewState())
        MetaView()
            .environmentObject(test)
            .environmentObject(MetaViewState())
    }
}
#endif
