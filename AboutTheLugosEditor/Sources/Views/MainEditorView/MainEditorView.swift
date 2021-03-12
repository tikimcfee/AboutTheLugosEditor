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
        HStack(spacing: 0) {
            HStack(spacing: 0) {
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
            .padding(4)
            .addBorder(Color.gray)
            .padding(4)
        }
        .padding(4)
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
import SharedAppTools
struct ContentView_Previews: PreviewProvider {
    static let test: MainEditorState = {
        let state = MainEditorState(converter: EscapingMarkdownConverter())
        state.selection = .none
        state.editingBody = "# Hello, world!"
        
        return state
    }()
    
    static let creator: ArticleCreator = {
        let creator = ArticleCreator(rootDirectory: URL(string: "google.com")!)
        return creator
    }()
    
    static var previews: some View {
        MainEditorView()
            .previewLayout(.fixed(width: 1280, height: 500.0))
            .environmentObject(test)
            .environmentObject(MetaViewState(creator: creator))
        MetaView()
            .environmentObject(test)
            .environmentObject(MetaViewState(creator: creator))
    }
}
#endif
