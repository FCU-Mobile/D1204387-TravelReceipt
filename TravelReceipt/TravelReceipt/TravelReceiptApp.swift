    //
    //  TravelReceiptApp.swift
    //  TravelReceipt
    //
    //  Created by YiJou  on 2025/11/12.
    //

import SwiftUI
import SwiftData
import CloudKit

@main
struct TravelReceiptApp: App {
    var modelContainer: ModelContainer = {
        let schema = Schema([
            Trip.self,
            Expense.self
            ExpenseCategory.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.buildwithharry.TravelReceipt"),
            cloudKitDatabase: .private("iCloud.com.buildwithharry.TravelReceipt")
        )
        
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
        .modelContainer(modelContainer)
    }
}

