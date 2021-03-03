import SwiftUI

public class WrappedBinding<Value> {
    private var current: Value
    init(_ start: Value) {
        self.current = start
    }
    lazy var binding = Binding<Value>(
        get: { self.current },
        set: { self.current = $0 }
    )
}
