//
//  BrowserDefaultsApp.swift
//  BrowserDefaults
//
//  Created by Enoch Chau on 4/5/25.
//

import SwiftUI

@main
struct BrowserDefaultsApp: App {
    @StateObject private var browserManager = BrowserManager()
    
    var body: some Scene {
        MenuBarExtra {
            ForEach(browserManager.browsers, id: \.name) { browser in
                Button {
                    browserManager.setDefaultBrowser(browserUrl: browser.url)
                } label: {
                    if browser.name == browserManager.selectedBrowser?.name {
                        Image(systemName: "checkmark")
                            .frame(width: 16) // Give it a fixed width
                        
                    }
                    Image(nsImage: browser.icon)
                    Text(browser.name)
                }
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            if let menuBarIcon = browserManager.selectedBrowser?.icon {
                Image(nsImage: menuBarIcon)
            } else {
                Image(systemName: "globe")
            }
        }
    }
}

class BrowserManager: ObservableObject {
    @Published var browsers: [Browser] = []
    @Published var selectedBrowser: Browser?
    
    struct Browser: Identifiable {
        let id: UUID = UUID()
        let name: String
        let url: URL
        let icon: NSImage
        
        init(url: URL) {
            self.url = url
            self.icon = NSWorkspace.shared.icon(forFile: url.path)
            self.icon.size = NSSize(width: 16, height: 16)
            self.name = Browser.formatBrowserName(browserUrl: url)
        }
        
        static func formatBrowserName(browserUrl: URL) -> String {
            return (browserUrl.lastPathComponent as NSString).deletingPathExtension
        }
    }
    
    init(){
        let httpUrl = URL(string: "http://apple.com")!
        for url in NSWorkspace.shared.urlsForApplications(toOpen: httpUrl) {
            browsers.append(Browser(url: url))
        }
        if let selectedUrl = NSWorkspace.shared.urlForApplication(toOpen: httpUrl) {
            selectedBrowser = Browser(url:selectedUrl)
        }
    }
    
    func setDefaultBrowser(browserUrl: URL){
        NSWorkspace.shared.setDefaultApplication(at: browserUrl, toOpenURLsWithScheme: "http"){error in
            if error == nil {
                DispatchQueue.main.async {
                    
                    self.selectedBrowser = Browser(url:browserUrl)
                }
            }
        }
        
    }
    
}
