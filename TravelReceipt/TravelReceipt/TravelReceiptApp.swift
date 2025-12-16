    //
    //  TravelReceiptApp.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/12.
    //

import SwiftUI
import SwiftData

@main
struct TravelReceiptApp: App {
    var modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Trip.self, Expense.self)
        } catch {
            print("❌ ModelContainer creation failed: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
