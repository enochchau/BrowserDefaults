//
//  AppDelegate.swift
//  BrowserDefaults
//
//  Created by Enoch Chau on 4/5/25.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem!
    private var currentDefaultBrowser: URL?
    private var previousDefaultBrowserURL: URL?
    var pollingTimer: Timer?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set the icon (optional)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Switch Default Browser")
        }
        
        // Build the menu
        constructMenu()
        
        // Observe for changes to file labels, which includes default app changes
        pollingTimer = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(checkDefaultBrowser),
            userInfo: nil,
            repeats: true
        )
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        pollingTimer?.invalidate() // Stop the timer
    }
    
    func constructMenu() {
        let browserIdentifiers = NSWorkspace.shared.urlsForApplications(toOpen: URL(string: "http://apple.com")!)
        currentDefaultBrowser = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "http://apple.com")!)
        let menu = NSMenu()
        
        if browserIdentifiers.isEmpty {
            let noBrowsersItem = NSMenuItem(title: "No Browsers Found", action: nil, keyEquivalent: "")
            noBrowsersItem.isEnabled = false
            menu.addItem(noBrowsersItem)
        } else {
            // Sort the browser list alphabetically by name
            let browserList = browserIdentifiers.map{ (formatBrowserName(browser: $0), $0)}
                .filter { $0.1 != currentDefaultBrowser}
                .sorted { $0.0 < $1.0 }
            
            if let identifier = currentDefaultBrowser {
                let name = formatBrowserName(browser: identifier)
                let menuItem = NSMenuItem(title: name, action: nil, keyEquivalent: "")
                menuItem.representedObject = identifier // Store the bundle identifier
                let icon = NSWorkspace.shared.icon(forFile: identifier.path)
                icon.size = NSSize(width: 16, height: 16)
                menuItem.image = icon;
                menu.addItem(menuItem)
                menuItem.state = .on
                // this needs to happen on the main thread
                DispatchQueue.main.async {
                    // Set the icon (optional)
                    if let button = self.statusItem.button {
                        button.image = icon
                    }
                }
            }
            
            menu.addItem(NSMenuItem.separator())
            
            // Add the sorted browsers to the menu
            for (name, identifier) in browserList {
                if identifier == currentDefaultBrowser {
                    continue;
                }
                
                let menuItem = NSMenuItem(title: name, action: #selector(changeDefaultBrowser(_:)), keyEquivalent: "")
                menuItem.representedObject = identifier // Store the bundle identifier
                let icon = NSWorkspace.shared.icon(forFile: identifier.path)
                icon.size = NSSize(width: 16, height: 16)
                menuItem.image = icon;
                menu.addItem(menuItem)
            }
            
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func formatBrowserName(browser: URL) -> String {
        return (browser.lastPathComponent as NSString).deletingPathExtension
    }
    
    
    @objc func changeDefaultBrowser(_ sender: NSMenuItem) {
        if let browserIdentifier = sender.representedObject as? URL {
            NSWorkspace.shared.setDefaultApplication(at: browserIdentifier, toOpenURLsWithScheme: "http"){error in
                if error == nil {
                    self.constructMenu()
                }
            }
        }
    }
    
    @objc func checkDefaultBrowser() {
        if let currentDefaultURL = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "http://apple.com")!) {
            if currentDefaultURL != previousDefaultBrowserURL {
                // Perform actions
                previousDefaultBrowserURL = currentDefaultBrowser
                currentDefaultBrowser = currentDefaultURL
                constructMenu()
            }
        } else {
            print("Could not determine the current default browser.")
        }
    }
}
