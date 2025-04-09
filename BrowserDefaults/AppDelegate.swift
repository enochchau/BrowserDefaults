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
        
        // Add a menu item to display the current default brXowser
        let currentItem = NSMenuItem(
            title: "Default Browser: \((currentDefaultBrowser != nil) ? formatBrowserName(browser: currentDefaultBrowser!) : "Unknown")",
            action: nil,
            keyEquivalent: ""
        )
        currentItem.isEnabled = false // Make it non-selectable
        menu.addItem(currentItem)
        menu.addItem(NSMenuItem.separator())

        if browserIdentifiers.isEmpty {
            let noBrowsersItem = NSMenuItem(title: "No Browsers Found", action: nil, keyEquivalent: "")
            noBrowsersItem.isEnabled = false
            menu.addItem(noBrowsersItem)
        } else {
            // Sort the browser list alphabetically by name
            let browserList = browserIdentifiers.map{ (formatBrowserName(browser: $0), $0)}
                .sorted { $0.0 < $1.0 }
            
            // Add the sorted browsers to the menu
            for (name, identifier) in browserList {
                let menuItem = NSMenuItem(title: name, action: #selector(changeDefaultBrowser(_:)), keyEquivalent: "")
                menuItem.representedObject = identifier // Store the bundle identifier
                if identifier == currentDefaultBrowser {
                    menuItem.state = .on // Add a checkmark
                }
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
                self.constructMenu()
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
