import SwiftUI
import Combine

class LolBomb: ObservableObject {
    @Published var string: String = ""
    
    init() {
        loop()
    }
    
    func loop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 500 ) {
            self.string += "Hello, World! \(DispatchTime.now())\n\n"
            self.loop()
        }
    }
}

struct EditorView: View {
    
    @EnvironmentObject var editorState: ArticleEditorState
    
    var metaWindowContainer = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
        styleMask: [.titled, .miniaturizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: $editorState.articleBody)
                        .frame(minHeight: 240, maxHeight: .infinity)
                        .font(.custom("Menlo", fixedSize: 12))
                    
                    Button("Save Changes") {
                        editorState.saveArticleChangesRequested()
                    }
                    .disabled(editorState.saveButtonDisabled)
                    .keyboardShortcut("s", modifiers: [.command])
                    .padding()
                }
                
                PreviewView(evaluableJavascript: editorState.previewJavascriptInjection)
            }
            .padding(4)
        }.onAppear{
            let dcView = MetaView().environmentObject(editorState)
            self.metaWindowContainer.contentView = NSHostingView(rootView: dcView)
            self.metaWindowContainer.makeKeyAndOrderFront(nil)
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static let test: ArticleEditorState = {
        let state = ArticleEditorState()
        
        var summary = "no article here"
//        (0...256).forEach { _ in summary.append("x") }
        state.articleSummary = summary
        
        state.articleBody = "# Hello, world!"
        
        return state
    }()
    
    static var previews: some View {
        EditorView()
            .previewLayout(/*@START_MENU_TOKEN@*/.fixed(width: /*@START_MENU_TOKEN@*/910.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/768.0/*@END_MENU_TOKEN@*/)/*@END_MENU_TOKEN@*/)
            .environmentObject(test)
        MetaView()
            .environmentObject(test)
    }
}

