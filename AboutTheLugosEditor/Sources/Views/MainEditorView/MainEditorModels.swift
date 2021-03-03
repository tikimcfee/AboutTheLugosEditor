import Foundation
import SwiftUI
import SharedAppTools

enum Selection {
    case none
    case directory(Directory)
    case directoryArticle(EditingContainer)
    
    var directory: Directory? {
        switch self {
        case let .directory(directory):
            return directory
        case let .directoryArticle(container):
            return container.directory
        default:
            return nil
        }
    }
}

struct EditingContainer {
    let directory: Directory
    let article: ArticleFile
    var originalBody: String
    
    func canSaveWith(updated body: String) -> Bool {
        return body != originalBody
    }
}
