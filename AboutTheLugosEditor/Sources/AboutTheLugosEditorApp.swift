import SwiftUI
import Combine
import SharedAppTools

@main
struct AboutTheLugosEditorApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EditorView()
                .environmentObject(appDelegate.editorState)
                .environmentObject(appDelegate.metaViewState)
        }.commands {
            CommandMenu("Articles") {
                Button("Select root 'articles' directory") {
                    openDirectory(appDelegate.rootDirectorySelected)
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
        }
    }
}
