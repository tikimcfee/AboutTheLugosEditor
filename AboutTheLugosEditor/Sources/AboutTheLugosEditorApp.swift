import SwiftUI
import Combine
import SharedAppTools

@main
struct AboutTheLugosEditorApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainEditorView()
                .environmentObject(appDelegate.editorState)
                .environmentObject(appDelegate.metaViewState)
        }.commands {
            CommandGroup(replacing: .newItem) {
                Button("Select root 'articles' directory") {
                    openDirectory(appDelegate.rootDirectorySelected)
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
            CommandGroup(replacing: .help) {
                
            }
            CommandGroup(replacing: .saveItem) {
                Button("Save changes") {
                    if appDelegate.editorState.saveButtonDisabled { return }

                    appDelegate.editorState.saveArticleChangesRequested()
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
            CommandGroup(replacing: .sidebar) {
                
            }
            CommandGroup(replacing: .windowList) {
                
            }
            CommandGroup(replacing: .toolbar) {
                
            }
            CommandGroup(replacing: .printItem) {
                
            }
            CommandGroup(replacing: .importExport) {
                
            }
        }
    }
}
