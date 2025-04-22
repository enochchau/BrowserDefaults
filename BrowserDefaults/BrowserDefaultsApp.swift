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
    
    var currentBrowser: Browser? {
        return browserManager.selectedBrowser
    }
    
    var otherBrowsers: [Browser] {
        if let browser = currentBrowser {
            return browserManager.browsers.filter{ $0.name != browser.name}
        } else {
            return browserManager.browsers
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            VStack{
                if let browser = currentBrowser {
                    BrowserListItem(iconPath: browser.url.path, label: browser.name, checked: true, onClick: {
                        browserManager.setDefaultBrowser(browserUrl: browser.url)
                    })
                    Divider()
                }
                ForEach(otherBrowsers, id: \.name) { browser in
                    BrowserListItem(iconPath: browser.url.path, label: browser.name, checked: false, onClick: {
                        browserManager.setDefaultBrowser(browserUrl: browser.url)
                    })
                }
                Divider()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(alignment: .leading)
                .keyboardShortcut("q")
            }.padding(6)
        } label: {
            if let menuBarIcon = browserManager.selectedBrowser?.icon {
                Image(nsImage: menuBarIcon)
            } else {
                Image(systemName: "globe")
            }
        }
        .menuBarExtraStyle(.window)
    }
}

struct Browser: Identifiable {
    let id: UUID = UUID()
    let name: String
    let url: URL
    let icon: NSImage
    
    init(url: URL) {
        print(url.path)
        self.url = url
        self.icon = NSWorkspace.shared.icon(forFile: url.path)
        self.icon.size = NSSize(width: 16, height: 16)
        self.name = Browser.formatBrowserName(browserUrl: url)
    }
    
    static func formatBrowserName(browserUrl: URL) -> String {
        return (browserUrl.lastPathComponent as NSString).deletingPathExtension
    }
}

class BrowserManager: ObservableObject {
    @Published var browsers: [Browser] = []
    @Published var selectedBrowser: Browser?
    
    
    
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
