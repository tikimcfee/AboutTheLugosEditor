import Foundation
import SwiftUI
import SharedAppTools

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
