import SwiftUI
import Combine

struct EditorView: View {
    
    @EnvironmentObject var editorState: ArticleEditorState
    
    var body: some View {
        VStack {
            HStack {
                TextEditor(text: $editorState.articleBody)
                    .frame(minWidth: 300.0, minHeight: 320.0)
            }
            HStack {
                Button("Open Article") {
                    openDirectory(receiveDirectory)
                }
            }
        }
    }
    
    func receiveDirectory(_ result: DirectoryResult) {
        switch result {
        case .success(let directory):
            print(directory.childUrls)
        case .failure(let error):
            print(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView()
            .environmentObject(ArticleEditorState())
    }
}
