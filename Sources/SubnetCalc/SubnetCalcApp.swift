import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Ensure the main window becomes key and front
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}

@main
struct SubnetCalcApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        NSApplication.shared.setActivationPolicy(.regular)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 1000, height: 700)
        
        MenuBarExtra("SubnetCalc", systemImage: "network") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}
