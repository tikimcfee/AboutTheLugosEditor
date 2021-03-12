import Foundation
import SwiftUI
import SharedAppTools

class MetaViewState: ObservableObject {
    @Published var availableArticles: [ArticleFile] = []
    @Published var selectedArticle: ArticleFile? = nil
    
    @Published var deleteRequestItem: ArticleFile? = nil
    @Published var deleteError: Error? = nil
    
    var creator: ArticleCreator
    
    init(creator: ArticleCreator) {
        self.creator = creator
    }
    
    func requestDelete(_ article: ArticleFile) {
        do {
            try creator.delete(article: article.meta)
            if selectedArticle == article {
                selectedArticle = nil
            }
            deleteRequestItem = nil
            deleteError = nil
        } catch {
            deleteError = error
        }
    }
}
