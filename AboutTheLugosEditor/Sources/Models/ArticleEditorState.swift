import Foundation
import Combine
import SharedAppTools
import Ink

public class ArticleEditorState: ObservableObject {
    
    private let markdownQueue = DispatchQueue(label: "MarkdownProcessor", qos: .userInteractive)
    private let markdownParser = MarkdownParser()
    private var cancellables = Set<AnyCancellable>()
    
    // ArtifleFile.Meta
    @Published var articleName: String = "New Article"
    @Published var articleSummary: String = "(no summary)"
    @Published var articleId: String = "(no id)"
    
    // Article content and converted HTML
    private var originalBody: String = ""
    @Published var articleBody: String = ""
    @Published var articleHTML: String = ""
    
    // Public error to preview in a window
    @Published var receiveError: Error? = nil
    
    init() {
        $articleBody
            .receive(on: markdownQueue)
            .map { self.markdownParser.html(from: $0) }
            .receive(on: DispatchQueue.main)
            .sink { self.articleHTML = $0 }
            .store(in: &cancellables)
    }
    
    func receiveDirectory(_ result: DirectoryResult) {
        do {
            var state = ArticleSniffState()
            if let fileModel = try state.makeFrom(urls: try result.get().children) {
                let fileContents = try fileModel.articleContents()
                setPublishedState(body: fileContents, with: fileModel.meta)
            }
        } catch {
            receiveError = error
        }
    }
    
    private func setPublishedState(body: String, with meta: ArticleMeta) {
        objectWillChange.send()
        articleName = meta.name
        articleSummary = meta.summary
        articleId = meta.id
        originalBody = body
        articleBody = body
    }
    
    func saveCurrent(to path: URL) {
        // TODO: save article.md a and meta.json to a new 
    }
    
    func load(from path: URL) {
        // TODO: read a file and set internal fields
    }
}

