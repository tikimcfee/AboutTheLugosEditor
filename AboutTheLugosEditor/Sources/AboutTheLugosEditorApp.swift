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
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var cancellables = Set<AnyCancellable>()
    let editorState = ArticleEditorState()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("App launch", notification)
    }
}

