import Foundation
import SharedAppTools

class ResourceManager: ObservableObject {
    lazy var component: ArticleLoaderComponent = {
        let root = rootSubDirectory(named: "articles")
        let comp = ArticleLoaderComponent(rootDirectory: root)
        comp.onLoadStart = {
            
        }
        comp.onLoadStop = { [weak self] in
            self?.currentArticles = comp.currentArticles
        }
        comp.onLoadError = { error in
            print(error)
        }
        return comp
    }()
    
    @Published var currentArticles: [ArticleFile] = []
    
    public subscript(_ id: String) -> ArticleFile? {
        get { component.articleLookup[id] }
    }
    
    init() {
        
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

