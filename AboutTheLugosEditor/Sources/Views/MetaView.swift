import SwiftUI
import SharedAppTools

class MetaViewState: ObservableObject {
    public let resources = ResourceManager()
    
    public func viewAppeared() {
        resources.beginPolling()
    }
}

private let LongDateShortTime: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

extension ArticleFile: Hashable, Equatable, Identifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(meta.id)
    }
    
    public var id: String { meta.id }
    
    public static func == (_ left: ArticleFile, _ right: ArticleFile) -> Bool {
        return left.articleFilePath == right.articleFilePath
            && left.metaFilePath == right.metaFilePath
            && left.meta == right.meta
    }
    
    var metaDateDisplay: String {
        LongDateShortTime.string(from: Date(timeIntervalSince1970: meta.postedAt))
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
            info
            Divider()
                .frame(height: 2)
                .background(Color.blue)
            files
        }
    }
    
    private var files: some View {
        List(metaState.resources.currentArticles, selection: $editorState.sourceFile) { item in
            makeFileButton(item)
        }
    }
    
    private func makeFileButton(_ item: ArticleFile) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.meta.name)
                        .fontWeight(.heavy)
                        .font(.system(size: 16))
                    Text(item.metaDateDisplay)
                        .fontWeight(.light)
                        .font(.system(size: 12))
                }
                Text(item.meta.summary)
                    .font(.system(size: 10))
                    .italic()
                    .fontWeight(.light)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color(red: 0.3, green: 0.3, blue: 0.3, opacity: 0.25))
            .cornerRadius(4.0)
        }
    }
    
    private var info: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            infoRow("Path:") {
                Text(filePath)
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
        HStack(alignment: .center) {
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

