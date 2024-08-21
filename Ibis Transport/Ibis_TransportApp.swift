//
//  Ibis_TransportApp.swift
//  Ibis Transport
//
//  Created by appleshoops on 29/7/2024.
//

import SwiftUI
import SwiftData
import Alamofire

@main
struct Ibis_TransportApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: stationData.self)
    }
}
