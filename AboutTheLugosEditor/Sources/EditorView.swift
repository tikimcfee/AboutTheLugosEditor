import SwiftUI
import Combine

struct EditorView: View {
    
    @EnvironmentObject var editorState: ArticleEditorState
    
    var body: some View {
        VStack {
            HStack {
                TextEditor(text: $editorState.articleBody)
                    .frame(minWidth: 300.0, minHeight: 320.0)
                    .font(.custom("Menlo", fixedSize: 12))
                    .padding()
            }
            
            HStack {
                Button("Open Article") {
                    openDirectory(editorState.receiveDirectory)
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
            .environmentObject(ArticleEditorState())
    }
}
