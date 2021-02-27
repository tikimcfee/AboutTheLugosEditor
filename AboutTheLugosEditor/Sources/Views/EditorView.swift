import SwiftUI
import Combine

struct EditorView: View {
    
    @EnvironmentObject var editorState: ArticleEditorState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: $editorState.articleBody)
                        .frame(minHeight: 240, maxHeight: .infinity)
                        .font(.custom("Menlo", fixedSize: 12))
                    
                    Button("Commit") {
                        editorState.saveArticleChangesRequested()
                    }
                    .keyboardShortcut("s", modifiers: [.command])
                    .disabled(editorState.saveButtonDisabled)
                    .padding()
                }
                MarkdownHtmlView(htmlContent: $editorState.articleHTML)
            }
            .padding()
            
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .trailing, spacing: 4) {
                    labeledText("Title:", editorState.articleName)
                    labeledText("ID:", editorState.articleId)
                    summary("Summary:", editorState.articleSummary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Button("Open Article") {
                        openDirectory(editorState.receiveDirectory)
                    }
                    .keyboardShortcut("o", modifiers: [.command])
                    
                    
                }
                
            }
            .padding()
        }
    }
    
    private func labeledText(_ name: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(name)
                .bold()
            Spacer()
                .frame(width: 16.0)
            Text(value)
                .frame(width: 256, alignment: .leading)
        }
    }
    
    private func summary(_ name: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(name)
                .bold()
            Spacer()
                .frame(width: 16.0)
            ScrollView {
                Text(value)
                    .frame(width: 256, alignment: .leading)
            }
            .frame(maxHeight: 64)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let test: ArticleEditorState = {
        let state = ArticleEditorState()
        
        var summary = ""
        (0...256).forEach { _ in summary.append("x") }
        state.articleSummary = summary
        
        state.articleBody = "# Hello, world!"
        
        return state
    }()
    
    static var previews: some View {
        EditorView()
            .previewLayout(/*@START_MENU_TOKEN@*/.fixed(width: /*@START_MENU_TOKEN@*/910.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/768.0/*@END_MENU_TOKEN@*/)/*@END_MENU_TOKEN@*/)
            .environmentObject(test)
    }
}
