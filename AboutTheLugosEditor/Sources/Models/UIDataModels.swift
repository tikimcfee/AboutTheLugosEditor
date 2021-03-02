import Foundation
import Combine

typealias CancelSet = Set<AnyCancellable>

struct ScrollState: Equatable {
    var scroll: CGFloat = 0
    var height: CGFloat = 0
    var percent: CGFloat {
        height != 0 ? scroll / height : 0
    }
    
    var skipConsume: Bool = false
}
