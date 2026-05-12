//
//  KeyVaultAppApp.swift
//  KeyVaultApp
//
//  Created by Rayhan Islam Shuvro on 5/12/26.
//

import SwiftUI

@main
struct KeyVaultApp: App {
    @StateObject private var store = ProfileStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 600, minHeight: 400)
        }
    }
}
