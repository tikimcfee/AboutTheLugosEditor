import SwiftUI
import SharedAppTools

class MetaViewState: ObservableObject {
    public let resources = ResourceManager()
    
    init() {
        
    }
    
    public func viewAppeared() {
        resources.beginPolling()
    }
}

struct MetaView: View {
    
    @EnvironmentObject var editorState: ArticleEditorState
    @EnvironmentObject var metaState: MetaViewState
    
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
        VStack(spacing: 8) {
            files
            info
        }
//        .frame(maxWidth: 320)
        .padding()
    }
    
    private var files: some View {
        VStack {
            LazyVStack {
                ForEach(metaState.resources.currentArticles, id:\.meta.id) { item in
                    HStack {
                        Text(item.meta.id)
                        Text(item.meta.name)
                    }
                    Divider()
                }
            }
        }
    }
    
    private var info: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
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
    
    
    @ViewBuilder
    func infoRow<RightView: View>(
        _ name: String,
        @ViewBuilder _ content: () -> RightView
    ) -> some View {
        HStack(alignment: .top) {
            Text(name)
                .bold()
                .frame(maxWidth: 96, alignment: .trailing)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
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
    
    static let meta: MetaViewState = {
        let state = MetaViewState()
        state.resources.beginPolling()
        return state
    }()
    
    static var previews: some View {
        MetaView()
            .environmentObject(test)
            .environmentObject(meta)
    }
}

