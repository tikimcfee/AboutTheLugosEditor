import Foundation
import SwiftUI
import SharedAppTools

struct ArticleMetaEditor: View {
    enum Dismiss { case cancel, save(ArticleMeta) }
    
    @State var sourceMeta: ArticleMeta
    let onDismiss: (Dismiss) -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Name")
                TextField("Name", text: $sourceMeta.name)
            }.padding()
            
            VStack(alignment: .leading) {
                Text("ID")
                TextField("ID", text: $sourceMeta.id)
            }.padding()
            
            TextEditor(text: $sourceMeta.summary)
                .frame(height: 96)
                .padding()
            
            HStack {
                Button("Cancel") {
                    onDismiss(.cancel)
                }
                .foregroundColor(.red)
                .padding()
                
                Spacer()
                
                Button("Save") {
                    onDismiss(.save(sourceMeta))
                }
                .padding()
                .keyboardShortcut("s", modifiers: /*@START_MENU_TOKEN@*/.command/*@END_MENU_TOKEN@*/)
            }
            
        }.onExitCommand(perform: {
            onDismiss(.cancel)
        })
    }
}
