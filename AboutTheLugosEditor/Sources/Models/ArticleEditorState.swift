import Foundation
import Combine
import SharedAppTools
import MarkdownKit

public class ArticleEditorState: ObservableObject {
    
    public enum StateError: String, Error {
        case noFileToSave
    }
    
    private let markdownQueue = DispatchQueue(label: "MarkdownProcessor", qos: .userInitiated)
    private var cancellables = Set<AnyCancellable>()
    
    // ArtifleFile.Meta
    @Published var articleName: String = "New Article"
    @Published var articleSummary: String = "(no summary)"
    @Published var articleId: String = "(no id)"
    
    // Article content and converted HTML
    @Published var sourceDirectory: Directory?
    @Published var sourceFile: ArticleFile?
    @Published var articleBody: String = ""
    @Published private var originalBody: String = ""
    @Published var articleHTML: String = ""
    @Published var saveButtonDisabled: Bool = true
    
    // Preview data
    @Published var previewJavascriptInjection: String = ""
    
    // Public error to preview in a window
    @Published var receiveError: Error?

    init() {
        // Map markdown to HTML
        $articleBody
            .receive(on: markdownQueue)
            .map    (articleBodyUpdated)
            .receive(on: DispatchQueue.main)
            .sink   {
                (self.articleHTML,
                 self.previewJavascriptInjection,
                 self.saveButtonDisabled) = $0
            }
            .store  (in: &cancellables)
        
        // If body changes, we have a new file, or it was reset
        $originalBody
            .receive(on: DispatchQueue.main)
            .sink   { _ in self.saveButtonDisabled = true }
            .store  (in: &cancellables)
    }
    
    func receiveDirectory(_ result: DirectoryResult) {
        switch result {
        case .failure(let error):
            receiveError = error
        case .success(let directory):
            do {
                var state = ArticleSniffState()
                if let fileModel = try state.makeFrom(urls: directory.children) {
                    let fileContents = try fileModel.articleContents()
                    setStateFrom(body: fileContents, with: fileModel, parent: directory)
                }
            } catch {
                receiveError = error
            }
        }
    }
    
    private func articleBodyUpdated(_ updatedBody: String) -> (String, String, Bool) {
        let markdown = MarkdownParser.standard.parse(updatedBody)
        let html = HtmlGenerator.standard.generate(doc: markdown)
        let escaped = html.convertedToBodyInjectionJavascriptString
        
        let disableSaveButton = sourceFile == nil
            || updatedBody == originalBody
        
        return (html, escaped, disableSaveButton)
    }
    
    func saveArticleChangesRequested() {
        guard let file = sourceFile else {
            receiveError = StateError.noFileToSave
            return
        }
        
        do {
            try articleBody.write(toFile: file.articleFilePath.path, atomically: true, encoding: .utf8)
            originalBody = articleBody
        } catch {
            receiveError = error
        }
    }
}

private extension ArticleEditorState {
    private func setStateFrom(body: String, with file: ArticleFile, parent: Directory) {
        objectWillChange.send()
        sourceDirectory = parent
        sourceFile = file
        articleName = file.meta.name
        articleSummary = file.meta.summary
        articleId = file.meta.id
        originalBody = body // updates canSave state via publisher
        articleBody = body  // updates htmlBody via publisher
    }
}
