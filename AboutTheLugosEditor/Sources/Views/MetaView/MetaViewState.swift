import Foundation
import SwiftUI
import SharedAppTools

class MetaViewState: ObservableObject {
    @Published var availableArticles: [ArticleFile] = []
    @Published var selectedArticle: ArticleFile? = nil
}
