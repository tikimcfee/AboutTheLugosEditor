import SwiftUI
import SharedAppTools

struct MetaView: View {

    @EnvironmentObject var metaState: MetaViewState
    
    var body: some View {
        VStack(spacing: 8) {
            info
            Divider().frame(height: 2)
            files
        }
        .padding(8)
        .sheet(item: $metaState.deleteRequestItem) { article in
            VStack {
                Spacer()
                Text("Delete '\(article.meta.name)'?")
                Spacer()
                HStack {
                    Button("Cancel") {
                        metaState.deleteRequestItem = nil
                    }
                    .keyboardShortcut(.delete)
                    
                    Spacer()
                    
                    Button("Confirm") {
                        metaState.requestDelete(article)
                    }
                    .keyboardShortcut(.return, modifiers: [.command])
                }.padding()
            }
            .padding()
            .frame(width: 320, height: 256, alignment: .center)
        }
    }
    
    private var files: some View {
        List(metaState.availableArticles, selection: $metaState.selectedArticle) { item in
            HStack {
                makeDeleteButton(item)
                makeFileButton(item).onTapGesture {
                    metaState.selectedArticle = item
                }
            }
        }
        .listStyle(PlainListStyle())
        .padding(0)
    }
    
    private func makeDeleteButton(_ item: ArticleFile) -> some View {
        Image(systemName: "xmark.square.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundColor(Color.red)
            .onTapGesture { metaState.deleteRequestItem = item }
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
            .background(
                metaState.selectedArticle == item
                    ? Color(red: 0.3, green: 0.3, blue: 0.8, opacity: 0.25)
                    : Color(red: 0.3, green: 0.3, blue: 0.3, opacity: 0.25)
            )
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

#if DEBUG
struct MetaView_Previews: PreviewProvider {
    static let test: MainEditorState = {
        let state = MainEditorState(converter: EscapingMarkdownConverter())
        
        state.editingBody = "# Hello, world!"
        
        return state
    }()
    
    static let articleMeta = ArticleMeta(
        id: "some-id-here",
        name: "The articleName",
        summary: "Words summary and then other things that EXTMRELY LONG and worlds and stuffstuffstuff",
        postedAt: Date().timeIntervalSince1970
    )
    
    static let file = ArticleFile(
        meta: articleMeta,
        metaFilePath: URL(string: "google.com")!,
        articleFilePath: URL(string: "google.com")!
    )
    
    static let creator = ArticleCreator(
        rootDirectory: URL(string: "apple.com")!
    )
    
    static let meta: MetaViewState = {
        let state = MetaViewState(creator: creator)
        state.availableArticles = [
            file, file, file
        ]
        return state
    }()
    
    static let wrapped = WrappedBinding(file)
    
    static var previews: some View {
        MetaView()
            .environmentObject(test)
            .environmentObject(meta)
    }
}
#endif
