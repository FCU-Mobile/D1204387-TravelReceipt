    //
    //  AddExpenseView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let trip: Trip
    
        // MARK: - Form State
    @State private var amount: String = ""
    @State private var currency: String = "TWD"
    @State private var date: Date = Date()
    @State private var category: ExpenseCategory = .miscellaneous
    @State private var storeName: String = ""
    @State private var notes: String = ""
    
        // 常用貨幣
    private let currencies = ["TWD", "CNY", "JPY", "USD", "EUR", "HKD", "KRW"]
    
        // 驗證：金額必須大於 0
    private var isValid: Bool {
        guard let value = Double(amount), value > 0 else {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                    // MARK: - 金額區塊
                Section("金額") {
                    HStack {
                        TextField("輸入金額", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                        
                        Picker("貨幣", selection: $currency) {
                            ForEach(currencies, id: \.self) { curr in
                                Text(curr).tag(curr)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                }
                
                    // MARK: - 分類區塊
                Section("分類") {
                    Picker("選擇分類", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            HStack {
                                Text(cat.icon)
                                Text(cat.displayName)
                            }
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                    // MARK: - 詳細資訊
                Section("詳細資訊") {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                    
                    TextField("商家名稱", text: $storeName)
                    
                    TextField("備註（選填）", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("新增費用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
        // MARK: - Save Method
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            amount: amountValue,
            currency: currency,
            date: date,
            storeName: storeName.isEmpty ? nil : storeName,
            notes: notes.isEmpty ? nil : notes,
            trip: trip,
            category: category
        )
        
        modelContext.insert(expense)
        
            // 加入到 trip 的 expenses
        trip.addExpense(expense)
        
        dismiss()
    }
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
    let trip = Trip(
        name: "測試行程",
        destination: "東京",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 3)
    )
    container.mainContext.insert(trip)
    
    return AddExpenseView(trip: trip)
        .modelContainer(container)
}
