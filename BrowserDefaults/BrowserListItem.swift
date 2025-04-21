//
//  ContentView.swift
//  BrowserDefaults
//
//  Created by Enoch Chau on 4/5/25.
//

import SwiftUI

struct BrowserListItem: View {
    let iconPath: String
    let label: String
    let checked: Bool
    let onClick: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onClick?()
        }){
            HStack{
                if self.checked {
                    Image(systemName: "checkmark")
                        .frame(width: 16,height: 16) // Give it a fixed width
                } else {
                    Color.clear
                        .frame(width: 16, height: 16)
                }
                Image(nsImage: iconFromIconPath())
                Text(self.label)
            }
        }.buttonStyle(PlainButtonStyle())
    }
    
    func iconFromIconPath() -> NSImage {
        let icon = NSWorkspace.shared.icon(forFile: self.iconPath)
        icon.size = NSSize(width: 16, height: 16)
        return icon
    }
}

#Preview {
    List{
        BrowserListItem(iconPath: "/Applications/Google Chrome.app", label: "Google Chrome", checked: true, onClick: nil)
        BrowserListItem(iconPath: "/Applications/Google Chrome.app", label: "Google Chrome", checked: false, onClick: nil)
    }
}
