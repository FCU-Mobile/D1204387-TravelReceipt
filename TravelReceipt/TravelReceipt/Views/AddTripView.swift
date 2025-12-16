    //
    //  AddTripView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData
import SwiftDate

struct AddTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
        // MARK: - Form State
    @State private var name: String = ""
    @State private var destination: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date() + 1.days // 預設隔天
    @State private var budgetString: String = ""
    @State private var notes: String = ""
    
        // 驗證：名稱和目的地必填
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !destination.trimmingCharacters(in: .whitespaces).isEmpty &&
        endDate >= startDate
    }
    
    var body: some View {
        NavigationStack {
            Form {
                    // MARK: - 基本資訊
                Section("基本資訊") {
                    TextField("行程名稱", text: $name)
                    TextField("目的地", text: $destination)
                }
                
                    // MARK: - 日期
                Section("日期") {
                    DatePicker("開始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("結束日期", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                
                    // MARK: - 預算（選填）
                Section {
                    HStack {
                        TextField("預算金額", text: $budgetString)
                            .keyboardType(.decimalPad)
                        Text("元")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("預算")
                } footer: {
                    Text("選填，可用於追蹤支出進度")
                }
                
                    // MARK: - 備註（選填）
                Section("備註") {
                    TextField("備註（選填）", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
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
                    .disabled(!isValid)
                }
            }
        }
    }
    
        // MARK: - Save Method
    private func saveTrip() {
        let budget: Double? = Double(budgetString)
        
        let trip = Trip(
            name: name.trimmingCharacters(in: .whitespaces),
            destination: destination.trimmingCharacters(in: .whitespaces),
            startDate: startDate,
            endDate: endDate,
            totalBudget: budget,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(trip)
        dismiss()
    }
}

    // MARK: - Preview
#Preview {
    AddTripView()
        .modelContainer(for: [Trip.self, Expense.self], inMemory: true)
}
