//
//  SunoonApp.swift
//  Sunoon
//
//  Created by Mohammed Omar on 26/08/2026.
//

import SwiftUI
import CoreData

@main
struct SunoonApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
