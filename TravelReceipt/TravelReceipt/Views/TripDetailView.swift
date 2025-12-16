    //
    //  TripDetailView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let trip: Trip
    @State private var showingAddExpense = false
    
        // 取得該行程的費用，按日期排序
    private var sortedExpenses: [Expense] {
        (trip.expenses ?? []).sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
                // MARK: - 行程資訊
            Section("行程資訊") {
                LabeledContent("目的地", value: trip.destination ?? "未知")
                LabeledContent("日期") {
                    Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) — \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                }
                LabeledContent("天數", value: "\(trip.durationInDays) 天")
                
                if let budget = trip.totalBudget, budget > 0 {
                    LabeledContent("預算", value: formatAmount(budget) + " 元")
                }
                
                if let notes = trip.notes, !notes.isEmpty {
                    LabeledContent("備註", value: notes)
                }
            }
            
                // MARK: - 統計摘要
            Section("統計摘要") {
                LabeledContent("總支出", value: formatAmount(trip.totalExpenses) + " 元")
                LabeledContent("費用筆數", value: "\(trip.expenses?.count ?? 0) 筆")
                
                if let budget = trip.totalBudget, budget > 0 {
                    let remaining = budget - trip.totalExpenses
                    LabeledContent("剩餘預算") {
                        Text(formatAmount(remaining) + " 元")
                            .foregroundStyle(remaining >= 0 ? .green : .red)
                    }
                }
            }
            
                // MARK: - 分類統計
            if !sortedExpenses.isEmpty {
                Section("分類統計") {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        let total = totalForCategory(category)
                        if total > 0 {
                            LabeledContent {
                                Text(formatAmount(total) + " 元")
                            } label: {
                                HStack {
                                    Text(category.icon)
                                    Text(category.displayName)
                                }
                            }
                        }
                    }
                }
            }
            
                // MARK: - 費用明細
            Section("費用明細") {
                if sortedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("尚無費用", systemImage: "receipt")
                    } description: {
                        Text("點擊右上角 + 新增費用")
                    }
                } else {
                    ForEach(sortedExpenses) { expense in
                        ExpenseRowView(expense: expense)
                    }
                    .onDelete(perform: deleteExpenses)
                }
            }
        }
        .navigationTitle(trip.name.isEmpty ? "未命名行程" : trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddExpense = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(trip: trip)
        }
    }
    
        // MARK: - Helper Methods
    private func formatAmount(_ value: Double) -> String {
        String(format: "%.0f", value)
    }
    
    private func totalForCategory(_ category: ExpenseCategory) -> Double {
        sortedExpenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expense = sortedExpenses[index]
            modelContext.delete(expense)
        }
    }
}

    // MARK: - Expense Row View
struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
                // 分類圖示
            Text(expense.category.icon)
                .font(.title2)
            
                // 資訊
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.storeName ?? "未知商家")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    Text(expense.category.displayName)
                    Text("·")
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
                // 金額
            VStack(alignment: .trailing) {
                Text(String(format: "%.0f", expense.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(expense.currency ?? "TWD")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
    let trip = Trip(
        name: "東京出差",
        destination: "東京",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 5),
        totalBudget: 50000
    )
    container.mainContext.insert(trip)
    
    return NavigationStack {
        TripDetailView(trip: trip)
    }
    .modelContainer(container)
}
