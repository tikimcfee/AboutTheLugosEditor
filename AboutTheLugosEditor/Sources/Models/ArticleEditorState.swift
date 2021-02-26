import Foundation
import Combine
import SharedAppTools

public class ArticleEditorState: ObservableObject {
    
    @Published var articleName: String = "New Article"
    @Published var articleSummary: String = "(no summary)"
    @Published var articleBody: String = ""
    
    func saveCurrent(to path: URL) {
        // TODO: save article.md a and meta.json to a new 
    }
    
    func load(from path: URL) {
        // TODO: read a file and set internal fields
    }
}

