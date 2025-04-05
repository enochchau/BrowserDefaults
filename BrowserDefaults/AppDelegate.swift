//
//  AppDelegate.swift
//  BrowserDefaults
//
//  Created by Enoch Chau on 4/5/25.
//

import Foundation
import AppKit
import Cocoa
import CoreServices // Add this line
import UniformTypeIdentifiers

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem!
    private var currentDefaultBrowser: String = ""
    var pollingTimer: Timer?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set the icon (optional)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Switch Default Browser")
        }
        
        // Get the initial default browser
        updateCurrentDefaultBrowser()
        
        // Build the menu
        constructMenu()
        
        // Observe for changes to file labels, which includes default app changes
        pollingTimer = Timer.scheduledTimer(
            timeInterval: 5.0, // Example interval
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
        let menu = NSMenu()
        
        // Add a menu item to display the current default brXowser
        let currentItem = NSMenuItem(
            title: "Default Browser: \(currentDefaultBrowser)",
                         action: nil,
                         keyEquivalent: ""
        )
        currentItem.isEnabled = false // Make it non-selectable
        menu.addItem(currentItem)
        menu.addItem(NSMenuItem.separator())
        
        // Get a list of installed browsers and add them to the menu (sorted alphabetically)
        if let browserIdentifiers = LSCopyAllHandlersForURLScheme("http" as CFString)?.takeRetainedValue() as? [String] {
            var browserList: [(name: String, identifier: String)] = []
            for identifier in browserIdentifiers {
                if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: identifier) {
                    let appName = appURL.deletingPathExtension().lastPathComponent
                    browserList.append((name: appName, identifier: identifier))
                }
            }
            
            // Sort the browser list alphabetically by name
            browserList.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            
            // Add the sorted browsers to the menu
            for (name, identifier) in browserList {
                let menuItem = NSMenuItem(title: name, action: #selector(changeDefaultBrowser(_:)), keyEquivalent: "")
                menuItem.representedObject = identifier // Store the bundle identifier
                if identifier == LSCopyDefaultHandlerForURLScheme("http" as CFString)?.takeRetainedValue() as? String {
                    menuItem.state = .on // Add a checkmark
                }
                menu.addItem(menuItem)
            }
        } else {
            let noBrowsersItem = NSMenuItem(title: "No Browsers Found", action: nil, keyEquivalent: "")
            noBrowsersItem.isEnabled = false
            menu.addItem(noBrowsersItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func changeDefaultBrowser(_ sender: NSMenuItem) {
        if let browserIdentifier = sender.representedObject as? String {
            LSSetDefaultHandlerForURLScheme("http" as CFString, browserIdentifier as CFString)
            LSSetDefaultHandlerForURLScheme("https" as CFString, browserIdentifier as CFString)
            updateCurrentDefaultBrowser()
            constructMenu() // Rebuild the menu to update the current browser display
            // Schedule checkDefaultBrowser to run after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.checkDefaultBrowser()
            }
        }
    }
    
    func updateCurrentDefaultBrowser() {
        if let currentIdentifier = LSCopyDefaultHandlerForURLScheme("http" as CFString)?.takeRetainedValue() as? String,
           let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: currentIdentifier) {
            currentDefaultBrowser = appURL.deletingPathExtension().lastPathComponent
            print("Updated currentDefaultBrowser: \(currentDefaultBrowser)")
        } else {
            currentDefaultBrowser = "Unknown"
            print("Updated currentDefaultBrowser: Unknown")
        }
    }
    
    var previousDefaultBrowserURL: URL?
    @objc func checkDefaultBrowser() {
        if let currentDefaultURL = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "http://example.com")!) {
            if currentDefaultURL != previousDefaultBrowserURL {
                print("Default browser changed to: \(currentDefaultURL.path)")
                // Perform actions
                previousDefaultBrowserURL = currentDefaultURL
                
                updateCurrentDefaultBrowser()
                constructMenu()
            }
        } else {
            print("Could not determine the current default browser.")
        }
    }
}
