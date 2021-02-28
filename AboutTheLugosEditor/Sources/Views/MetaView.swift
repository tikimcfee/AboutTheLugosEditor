import SwiftUI

struct MetaView: View {
    
    @EnvironmentObject var editorState: ArticleEditorState
    
    private var filePath: String {
        editorState.sourceDirectory?.root.path ?? "No article selected"
    }
    
    private var articleName: String {
        editorState.sourceFile?.meta.name ?? "-"
    }
    
    private var articleId: String {
        editorState.sourceFile?.meta.id ?? "-"
    }
    
    private var articleSummary: String {
        editorState.sourceFile?.meta.summary ?? "-"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            info
        }
//        .frame(maxWidth: 320)
        .padding()
    }
    
    @ViewBuilder
    func infoRow<Right: View>(
        _ name: String,
        @ViewBuilder _ content: () -> Right
    ) -> some View {
        HStack(alignment: .top) {
            Text(name)
                .bold()
                .frame(maxWidth: 96, alignment: .trailing)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var info: some View {
        VStack(alignment: .leading, spacing: 8) {
            infoRow("Path:") {
                Text(filePath)
                    .baselineOffset(-2)
                    .fontWeight(.light)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
            }
            Divider()
            infoRow("Files:") {
                LazyVStack(alignment: .leading, spacing: 4) {
                    if let dir = editorState.sourceDirectory {
                        ForEach(dir.children, id: \.path) { item in
                            Text(item.lastPathComponent)
                                .fontWeight(.light)
                                .font(.footnote)
                        }
                    } else {
                        Text("-")
                            .italic()
                            .fontWeight(.light)
                    }
                }
            }
            Divider()
            infoRow("Title:") { Text(articleName) }
            infoRow("ID:") { Text(articleId) }
            infoRow("Summary:") {
                ScrollView {
                    Text(articleSummary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
        }
    }
}

// MARK: - Previews

struct MetaView_Previews: PreviewProvider {
    static let test: ArticleEditorState = {
        let state = ArticleEditorState()
        
        var summary = "no article here"
        (0...40).forEach { _ in summary.append(" ... .. ") }
        state.articleSummary = summary
        state.articleBody = "# Hello, world!"
        
        return state
    }()
    
    static var previews: some View {
        MetaView()
            .environmentObject(test)
    }
}

