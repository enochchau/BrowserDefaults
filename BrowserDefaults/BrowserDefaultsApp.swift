//
//  BrowserDefaultsApp.swift
//  BrowserDefaults
//
//  Created by Enoch Chau on 4/5/25.
//

import SwiftUI

@main
struct BrowserDefaultsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
      var body: some Scene {
        Settings {
          Text("Settings or main app window")
        }
      }
}
