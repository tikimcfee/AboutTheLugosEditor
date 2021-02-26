import SwiftUI
import Combine

struct EditorView: View {
    @EnvironmentObject var editorState: ArticleEditorState
    
    var body: some View {
        TextEditor(text: $editorState.articleBody)
            .frame(minWidth: 300.0, minHeight: 320.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
            .environmentObject(ArticleEditorState())
    }
}
