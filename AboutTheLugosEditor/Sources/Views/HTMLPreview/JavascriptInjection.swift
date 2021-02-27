import Foundation

extension String {
    private var hexEncodedContent: String {
        reduce(into: "") { result, char in
            char.appendHexEncoding(to: &result)
        }
    }
    
    var convertedToBodyInjectionJavascriptString: String {
"""
document.body.innerHTML='\(hexEncodedContent)'
"""
    }
}

private extension Character {
    static var cache = [Self: String]()
    
    var shouldEncodeForJS: Bool {
        guard let scalar = unicodeScalars.first,
              CharacterSet.alphanumerics.contains(scalar) else {
            return true
        }
        return false
    }
    
    func appendHexEncoding(to target: inout String) {
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
}

private extension UInt8 {
    var jsHexEncoded: String {
        "\\x\(String(format: "%02X", self))"
    }
}
