//
//  AddTripView.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/14.
//

import SwiftUI
import SwiftData

struct AddTripView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本資訊") {
                    TextField("行程名稱", text: $name)
                    TextField("目的地", text: $destination)
                }
                
                Section("日期") {
                    DatePicker("開始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("結束日期", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("新增行程")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveTrip()
                    }
                    .disabled(name.isEmpty || destination.isEmpty)
                }
            }
        }
    }
    
    private func saveTrip() {
        let trip = Trip(
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate
        )
        modelContext.insert(trip)
        dismiss()
    }
}

#Preview {
    AddTripView()
        .modelContainer(for: Trip.self, inMemory: true)
}
