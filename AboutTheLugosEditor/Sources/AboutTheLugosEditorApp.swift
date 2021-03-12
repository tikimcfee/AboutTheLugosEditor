import SwiftUI
import Combine
import SharedAppTools

@main
struct AboutTheLugosEditorApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var newMeta: ArticleMeta? = nil
    
    var body: some Scene {
        WindowGroup {
            MainEditorView()
                .sheet(item: $newMeta) { meta in
                    ArticleMetaEditor(sourceMeta: meta) {
                        if case let .save(updated) = $0 {
                            appDelegate.newArticleRequested(updated)
                        }
                        newMeta = nil
                    }
                }
                .environmentObject(appDelegate.editorState)
                .environmentObject(appDelegate.metaViewState)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Select Root Directory") {
                    openDirectory(appDelegate.rootDirectorySelected)
                }
                .keyboardShortcut("o", modifiers: [.command])
                Button("New Article") {
                    newMeta = ArticleMeta(
                        id: UUID().uuidString,
                        name: "New Article",
                        summary: "Add a summary",
                        postedAt: Date().timeIntervalSince1970
                    )
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
            CommandGroup(replacing: .saveItem) {
                Button("Save changes") {
                    if appDelegate.editorState.saveButtonDisabled { return }
                    appDelegate.editorState.saveArticleChangesRequested()
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
            CommandGroup(replacing: .help) { }
            CommandGroup(replacing: .sidebar) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .toolbar) { }
            CommandGroup(replacing: .printItem) { }
            CommandGroup(replacing: .importExport) { }
        }
    }
}

#if DEBUG
struct AppRoot_Previews: PreviewProvider {
    static let meta: ArticleMeta = {
        let meta = ArticleMeta(
            id: UUID().uuidString,
            name: "New Article",
            summary: "Add a summary",
            postedAt: Date().timeIntervalSince1970
        )
        
        return meta
    }()
    
    static let metaBinding = WrappedBinding<ArticleMeta>(Self.meta)
    
    static var previews: some View {
        ArticleMetaEditor(sourceMeta: metaBinding.binding.wrappedValue) {
            _ in
        }
    }
}
#endif
