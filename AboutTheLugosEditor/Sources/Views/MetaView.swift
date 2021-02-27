import SwiftUI

struct MetaView: View {
    
    @EnvironmentObject var editorState: ArticleEditorState
    
    var body: some View {
        VStack(spacing: 0) {
            info
        }
        .padding()
    }
    
    private var info: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .trailing, spacing: 4) {
                Text("Title:").bold()
                Text("ID:").bold()
                Text("Summary:").bold()
            }
            Spacer().frame(width: 8)
            VStack(alignment: .leading, spacing: 4) {
                Text(editorState.articleName)
                Text(editorState.articleId)
                ScrollView {
                    Text(editorState.articleSummary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: 256, maxHeight: 128)
            }
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

// MARK: - Previews

struct MetaView_Previews: PreviewProvider {
    static let test: ArticleEditorState = {
        let state = ArticleEditorState()
        
        var summary = "no article here"
//        (0...256).forEach { _ in summary.append("x") }
        state.articleSummary = summary
        state.articleBody = "# Hello, world!"
        
        return state
    }()
    
    static var previews: some View {
        MetaView()
            .environmentObject(test)
    }
}

