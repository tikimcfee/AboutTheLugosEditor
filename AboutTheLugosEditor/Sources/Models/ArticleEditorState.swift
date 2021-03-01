import Foundation
import Combine
import SharedAppTools
import MarkdownKit

enum Selection {
    case none
    case directory(Directory)
    case directoryArticle(EditingContainer)
}

struct EditingContainer {
    let directory: Directory
    let article: ArticleFile
    var originalBody: String
    
    func canSaveWith(updated body: String) -> Bool {
        return body != originalBody
    }
}

public class ArticleEditorState: ObservableObject {
    
    public enum StateError: String, Error {
        case noFileToSave
    }
    
    private let markdownQueue = DispatchQueue(label: "MarkdownProcessor", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    
    // Data locations
    @Published var selection: Selection = .none
    
    // Article content and converted HTML
    @Published var editingBody: String = ""
    @Published var articleHTML: String = ""
    @Published var previewJavascriptInjection: String = ""
    
    // State
    @Published var saveButtonDisabled: Bool = true
    
    // Public error to preview in a window
    @Published var receiveError: Error?

    init() {
        // Map markdown to HTML
        $editingBody
            .receive(on: markdownQueue)
            .map    (articleBodyUpdated)
            .receive(on: DispatchQueue.main)
            .sink   {
                (self.articleHTML,
                 self.previewJavascriptInjection,
                 self.saveButtonDisabled) = $0
            }
            .store  (in: &cancellables)
    }
    
    private func articleBodyUpdated(_ updatedBody: String) -> (String, String, Bool) {
        let markdown = MarkdownParser.standard.parse(updatedBody)
        let html = HtmlGenerator.standard.generate(doc: markdown)
        let escaped = html.convertedToBodyInjectionJavascriptString
        
        var canSave: Bool
        switch selection {
        case .directoryArticle(let container):
            canSave = container.originalBody != updatedBody
        case .none, .directory:
            canSave = false
        }
        
        return (html, escaped, !canSave)
    }
    
    func saveArticleChangesRequested() {
        guard case var .directoryArticle(container) = selection else {
            receiveError = StateError.noFileToSave
            return
        }
        
        do {
            let path = container.article.articleFilePath.path
            try editingBody.write(toFile: path, atomically: true, encoding: .utf8)
            container.originalBody = editingBody
            selection = .directoryArticle(container)
        } catch {
            receiveError = error
        }
    }
}
