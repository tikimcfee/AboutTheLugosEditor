import Foundation
import SwiftUI
import Combine
import SharedAppTools

enum DelegateError: String, Error {
    case metaSelectedEmptyArticleWithNonNilDirectory
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var cancellables = Set<AnyCancellable>()
    
    let converter: EscapingMarkdownConverter
    let resources: ResourceManager
    let editorState: MainEditorState
    let metaViewState: MetaViewState
    
    override init() {
        converter = EscapingMarkdownConverter()
        
        editorState = MainEditorState(
            converter: converter
        )
        
        resources = ResourceManager()
        
        metaViewState = MetaViewState()
        super.init()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("App launch", notification)
        
        metaViewState.$selectedArticle
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: newArticleSelected)
            .store(in: &cancellables)
        
        editorState.$selection
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: onSelectionChanged)
            .store(in: &cancellables)
        
        resources.$currentArticles
            .receive(on: DispatchQueue.main)
            .sink { self.metaViewState.availableArticles = $0 }
            .store(in: &cancellables)
    }
    
    func rootDirectorySelected(_ result: DirectoryResult) {
        switch result {
        case .success(let directory):
            editorState.selection = .directory(directory)
        case .failure(let error):
            editorState.receiveError = error
        }
    }
    
    private func onSelectionChanged(_ selection: Selection) {
        switch selection {
        case .none:
            editorState.editingBody = ""
            resources.selectedRootDirectory = nil
        case let .directory(directory):
            resources.selectedRootDirectory = directory.root
        case let .directoryArticle(container):
            resources.selectedRootDirectory = container.directory.root
            editorState.editingBody = container.originalBody
        }
    }
    
    private func newArticleSelected(_ selected: ArticleFile?) {
        guard let selected = selected else { return }
        do {
            let body = try selected.articleContents()
            switch editorState.selection {
            case let .directory(directory):
                editorState.editingBody = body
                editorState.selection = .directoryArticle(
                    EditingContainer(
                        directory: directory,
                        article: selected,
                        originalBody: body
                    )
                )
            case let .directoryArticle(container):
                editorState.editingBody = body
                editorState.selection = .directoryArticle(
                    EditingContainer(
                        directory: container.directory,
                        article: selected,
                        originalBody: body
                    )
                )
            case .none:
                throw DelegateError.metaSelectedEmptyArticleWithNonNilDirectory
            }
        } catch {
            editorState.receiveError = error
        }
    }
}

