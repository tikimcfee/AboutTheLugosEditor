import Foundation
import SharedAppTools

extension ArticleFile: Hashable, Equatable, Identifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(meta.id)
    }
    
    public var id: String { meta.id }
    
    public static func == (_ left: ArticleFile, _ right: ArticleFile) -> Bool {
        return left.articleFilePath == right.articleFilePath
            && left.metaFilePath == right.metaFilePath
            && left.meta == right.meta
    }
    
    var metaDateDisplay: String {
        LongDateShortTime.string(from: Date(timeIntervalSince1970: meta.postedAt))
    }
}

extension ArticleMeta: Identifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private let LongDateShortTime: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    return dateFormatter
}()
