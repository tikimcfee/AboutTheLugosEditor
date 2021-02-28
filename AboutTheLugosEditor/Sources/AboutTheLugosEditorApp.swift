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
                Button("Open") {
                    openDirectory(appDelegate.editorState.receiveDirectory)
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var cancellables = Set<AnyCancellable>()
    
    let editorState = ArticleEditorState()
    let metaViewState = MetaViewState()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("App launch", notification)
    }
}

