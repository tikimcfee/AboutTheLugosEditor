import Foundation

extension String {
    var hexEncodedContent: String {
        reduce(into: "") { result, char in
            char.appendHexEncoding(to: &result)
        }
    }
}

public extension Character {
    static var cache = [Self: String]()
    
    @inlinable func appendHexEncoding(to target: inout String) {
        let encoded = Self.cache[self] ?? {
            var encoded: String
            if let ascii = asciiValue, shouldEncodeForJS {
                encoded = ascii.jsHexEncoded
            } else {
                encoded = String(self)
            }
            Self.cache[self] = encoded
            return encoded
        }()
        target.append(encoded)
    }
    
    var shouldEncodeForJS: Bool {
        if let scalar = unicodeScalars.first,
           CharacterSet.alphanumerics.contains(scalar) {
            return false
        }
        return true
    }
}

public extension UInt8 {
    @inlinable var jsHexEncoded: String {
        "\\x\(String(format: "%02X", self))"
    }
}
