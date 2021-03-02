import Foundation
import Combine
import SharedAppTools
import MarkdownKit

class MainEditorState: ObservableObject {
    
    public enum StateError: String, Error {
        case noFileToSave
    }

    @Published var selection: Selection = .none
    @Published var saveButtonDisabled: Bool = true
    @Published var receiveError: Error?
    
    @Published var editingBody: String = ""
    @Published var previewJavascript: String = ""
    
    var cancellables = CancelSet()
    let converter: EscapingMarkdownConverter
    
    init(converter: EscapingMarkdownConverter) {
        self.converter = converter
        
        $editingBody
            .receive(on: DispatchQueue.global())
            .map(saveButtonIsDisabled)
            .combineLatest(converter.convertLiveEdits($editingBody))
            .receive(on: DispatchQueue.main)
            .sink { isDisabled, livePreview in
                self.saveButtonDisabled = isDisabled
                self.previewJavascript = livePreview
            }
            .store(in: &cancellables)
    }
    
    private func saveButtonIsDisabled(_ updatedBody: String) -> Bool {
        let saveIsDisabled: Bool
        switch selection {
        case .directoryArticle(let container):
            saveIsDisabled = container.originalBody == updatedBody
        case .none, .directory:
            saveIsDisabled = true
        }
        return saveIsDisabled
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
