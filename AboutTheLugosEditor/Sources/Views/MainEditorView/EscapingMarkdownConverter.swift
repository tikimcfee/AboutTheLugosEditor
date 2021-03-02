import Foundation
import SwiftUI
import MarkdownKit
import Combine

class EscapingMarkdownConverter: ObservableObject {
    private let markdownQueue = DispatchQueue(label: "MarkdownProcessor", qos: .userInitiated)
    
    func convertLiveEdits(_ editingBody: Published<String>.Publisher) -> AnyPublisher<String, Never> {
        editingBody
            .receive(on: markdownQueue)
            .map(markdownToEscapedHtml)
            .eraseToAnyPublisher()
    }
    
    public func markdownToEscapedHtml(_ updatedBody: String) -> String {
        let markdown = MarkdownParser.standard.parse(updatedBody)
        let html = HtmlGenerator.standard.generate(doc: markdown)
        let escaped = html.convertedToBodyInjectionJavascriptString
        
        return escaped
    }
}

extension String {
    var convertedToBodyInjectionJavascriptString: String {
"""
document.body.innerHTML='\(hexEncodedContent)';
"""
    }
}

