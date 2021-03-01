import SwiftUI
import SharedAppTools

class MetaViewState: ObservableObject {
    @Published var availableArticles: [ArticleFile] = []
    @Published var selectedArticle: ArticleFile? = nil
}

struct MetaView: View {

    @EnvironmentObject var metaState: MetaViewState
    
    var body: some View {
        VStack(spacing: 8) {
            info
            Divider().frame(height: 2)
            files
        }.padding(8)
    }
    
    private var files: some View {
        List(metaState.availableArticles, selection: $metaState.selectedArticle) { item in
            makeFileButton(item)
                .onTapGesture {
                    metaState.selectedArticle = item
                }
        }
    }
    
    private func makeFileButton(_ item: ArticleFile) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.meta.name)
                        .fontWeight(.heavy)
                        .font(.system(size: 16))
                    Text(item.metaDateDisplay)
                        .fontWeight(.light)
                        .font(.system(size: 12))
                }
                Text(item.meta.summary)
                    .font(.system(size: 10))
                    .italic()
                    .fontWeight(.light)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color(red: 0.3, green: 0.3, blue: 0.3, opacity: 0.25))
            .cornerRadius(4.0)
        }
    }
    
    private var info: some View {
        let path = metaState.selectedArticle?.articleFilePath.path ?? "No Path Selected"
        let title = metaState.selectedArticle?.meta.name ?? "-"
        let id = metaState.selectedArticle?.meta.id ?? "-"
        let summary = metaState.selectedArticle?.meta.summary ?? "-"
        
        return VStack(alignment: .leading, spacing: 8) {
            infoRow("Path:") {
                Text(path)
                    .fontWeight(.light)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
            }
            Divider()
            infoRow("Title:") { Text(title) }
            infoRow("ID:") { Text(id) }
            
            HStack(alignment: .top) {
                Text("Summary")
                    .bold()
                    .frame(maxWidth: 96, alignment: .trailing)
                ScrollView {
                    Text(summary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 256)
                .padding(4)
                .addBorder(Color.gray)
            }
        }
    }
    
    @ViewBuilder
    func infoRow<RightView: View>(
        _ name: String,
        @ViewBuilder _ content: () -> RightView
    ) -> some View {
        HStack(alignment: .center) {
            Text(name)
                .bold()
                .frame(maxWidth: 96, alignment: .trailing)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension View {
    public func addBorder<S>(_ content: S,
                             width: CGFloat = 1,
                             cornerRadius: CGFloat = 4) -> some View where S : ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
             .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}

// MARK: - Previews

struct MetaView_Previews: PreviewProvider {
    static let test: ArticleEditorState = {
        let state = ArticleEditorState()
        
        state.editingBody = "# Hello, world!"
        
        return state
    }()
    
    static let meta: MetaViewState = {
        let state = MetaViewState()
        
        return state
    }()
    
    static var previews: some View {
        MetaView()
            .environmentObject(test)
            .environmentObject(meta)
    }
}

