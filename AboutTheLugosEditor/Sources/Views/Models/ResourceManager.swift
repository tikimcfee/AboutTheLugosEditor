import Foundation
import SharedAppTools
import Combine

class ResourceManager: ObservableObject {
    lazy var component: ArticleLoaderComponent = {
        let root = rootSubDirectory(named: "articles")
        let loadingComponent = ArticleLoaderComponent(rootDirectory: root)
        loadingComponent.onLoadStart = {
            
        }
        loadingComponent.onLoadStop = {
            self.currentArticles = self.sortedArticle(loadingComponent.currentArticles)
        }
        loadingComponent.onLoadError = { error in
            print(error)
        }
        return loadingComponent
    }()
    
    @Published var currentArticles: [ArticleFile] = []
    
    public subscript(_ id: String) -> ArticleFile? {
        get { component.articleLookup[id] }
    }
    
    init() {
        
    }
    
    func sortedArticle(_ list: [ArticleFile]) -> [ArticleFile] {
        list.sorted { left, right in
            left.meta.postedAt < right.meta.postedAt
        }
    }
    
    func beginPolling() {
        component.kickoffArticleLoading()
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

