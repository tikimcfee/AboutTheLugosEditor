import Foundation
import SharedAppTools
import Combine

public class ResourceManager: ObservableObject {
    
    @Published var currentArticles: [ArticleFile] = []
    @Published var loadingError: Error? = nil
    
    private var cancellables = CancelSet()
    private let loadingComponent: ArticleLoaderComponent
    
    var selectedRootDirectory: URL {
        get { loadingComponent.rootDirectory }
        set { loadingComponent.rootDirectory = newValue }
    }
    
    public init(loadingComponent: ArticleLoaderComponent) {
        self.loadingComponent = loadingComponent
        
        loadingComponent.$currentArticles
            .map(sortedArticle)
            .assign(to: \.currentArticles, on: self)
            .store(in: &cancellables)
        
        loadingComponent.$loadingError
            .assign(to: \.loadingError, on: self)
            .store(in: &cancellables)
        
        loadingComponent.kickoffArticleLoading()
    }
    
    public subscript(_ id: String) -> ArticleFile? {
        get { loadingComponent.articleLookup[id] }
    }
    
    func sortedArticle(_ list: [ArticleFile]) -> [ArticleFile] {
        list.sorted { left, right in
            left.meta.postedAt > right.meta.postedAt
        }
    }
}

// * Read the list of available article bundle
//  - Includes article itself, and all files for article
// * Change name of article bundle
//  - Do this is the MetaView? Do this in the list?
//  - Might be safer to do from view
// * Reorder relative bundle order
//  - I think there needs to be a 'BundleInfo' that holds data
//  -- bundle name -> sort position
//  - I could use the ArticleMeta.id as the key...
//  - .. do I just set a date? Make the date modifiable?
//  - .. that makes a lot of sense.

