import Foundation
import Combine
import SharedAppTools

public class ArticleEditorState: ObservableObject {
    
    @Published var articleName: String = "New Article"
    @Published var articleSummary: String = "(no summary)"
    @Published var articleId: String = "(no id)"
    @Published var articleBody: String = ""
    
    @Published var receiveError: Error? = nil
    
    func receiveDirectory(_ result: DirectoryResult) {
        do {
            let directory = try result.get()
            var state = ArticleSniffState()
            if let fileModel = try state.makeFrom(urls: directory.children) {
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
        articleBody = body
        articleId = meta.id
    }
    
    func saveCurrent(to path: URL) {
        // TODO: save article.md a and meta.json to a new 
    }
    
    func load(from path: URL) {
        // TODO: read a file and set internal fields
    }
}

