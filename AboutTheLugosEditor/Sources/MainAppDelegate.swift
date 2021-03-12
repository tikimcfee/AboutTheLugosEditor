import Foundation
import SwiftUI
import Combine
import SharedAppTools

enum DelegateError: String, Error {
    case metaSelectedEmptyArticleWithNonNilDirectory
    case newArticleIdLookupFailed
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var cancellables = Set<AnyCancellable>()
    
    let markdownConverter: EscapingMarkdownConverter
    let resourceManager: ResourceManager
    let articleLoader: ArticleLoaderComponent
    var articleCreator: ArticleCreator
    let editorState: MainEditorState
    let metaViewState: MetaViewState
        
    override init() {
        self.markdownConverter = EscapingMarkdownConverter()
        
        // directory is a bad idea; maybe compute the child manually.
        // I guess the callback shouldn't do the processing... oof.
        // Also, 'selected' should probably be published throgh the whole app.
        let root = rootSubDirectory(named: "articles")
        let rootChildren = (try? root.defaultContents()) ?? []
        let rootDirectory = Directory(root: root, children: rootChildren)
        
        self.articleCreator = ArticleCreator(rootDirectory: root)
        
        let loader = ArticleLoaderComponent(rootDirectory: root)
        self.articleLoader = loader
        self.resourceManager = ResourceManager(loadingComponent: loader)
        
        self.editorState = MainEditorState(converter: markdownConverter)
        editorState.selection = .directory(rootDirectory)
        
        self.metaViewState = MetaViewState(creator: articleCreator)
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
        
        resourceManager.$currentArticles
            .receive(on: DispatchQueue.main)
            .sink { self.metaViewState.availableArticles = $0 }
            .store(in: &cancellables)
    }
    
    func rootDirectorySelected(_ result: DirectoryResult) {
        switch result {
        case .success(let directory):
            FileManager.default.changeCurrentDirectoryPath(directory.root.path)
            editorState.selection = .directory(directory)
            articleCreator.rootDirectory = directory.root
            metaViewState.creator = articleCreator
        case .failure(let error):
            editorState.receiveError = error
        }
    }
    
    func newArticleRequested(_ meta: ArticleMeta) {
        do {
            try articleCreator.createNew(article: "", with: meta)
            articleLoader.rootDirectory = articleLoader.rootDirectory
            guard let created = articleLoader.articleLookup[meta.id] else {
                throw articleLoader.loadingError ?? DelegateError.newArticleIdLookupFailed
            }
            metaViewState.selectedArticle = created
        } catch {
            editorState.receiveError = error
        }
    }
    
    private func deleteArticleRequested(_ meta: ArticleMeta) {
        do {
            try articleCreator.delete(article: meta)
            articleLoader.rootDirectory = articleLoader.rootDirectory
            metaViewState.deleteRequestItem = nil
            metaViewState.deleteError = nil
        } catch {
            metaViewState.deleteError = error
        }
    }
    
    private func onSelectionChanged(_ selection: Selection) {
        switch selection {
        case .none:
            editorState.editingBody = ""
            resourceManager.selectedRootDirectory = URL(fileURLWithPath: "")
        case let .directory(directory):
            resourceManager.selectedRootDirectory = directory.root
            articleCreator.rootDirectory = directory.root
        case let .directoryArticle(container):
            resourceManager.selectedRootDirectory = container.directory.root
            articleCreator.rootDirectory = container.directory.root
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

