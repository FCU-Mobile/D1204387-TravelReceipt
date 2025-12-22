    //
    //  TripDetailView.swift - 修復版
    //  正確轉換貨幣
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: Trip
    
    @State private var showingAddExpense = false
    @State private var showingEditTrip = false
    @State private var expenseToEdit: Expense? = nil
    
    @Query private var allExpenses: [Expense]
    
    private var sortedExpenses: [Expense] {
        allExpenses
            .filter { $0.trip?.id == trip.id }
            .sorted { $0.date > $1.date }
    }
    
        // ✅ 修復 1：正確轉換貨幣的總支出
    private var totalExpenses: Double {
        sortedExpenses.reduce(0) { sum, expense in
            let convertedAmount = trip.convertToPrimaryCurrency(
                amount: expense.amount,
                from: expense.currency
            )
            return sum + convertedAmount
        }
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
                    LabeledContent("預算", value: "\(budget.formattedAmount) \(trip.primaryCurrency)")
                }
                
                if let notes = trip.notes, !notes.isEmpty {
                    LabeledContent("備註", value: notes)
                }
            }
            
                // MARK: - 統計摘要
            Section("統計摘要") {
                    // ✅ 顯示幣別
                LabeledContent("總支出", value: "\(totalExpenses.formattedAmount) \(trip.primaryCurrency)")
                LabeledContent("費用筆數", value: "\(sortedExpenses.count) 筆")
                
                if let budget = trip.totalBudget, budget > 0 {
                    let remaining = budget - totalExpenses
                    LabeledContent("剩餘預算") {
                        Text("\(remaining.formattedAmount) \( trip.primaryCurrency)")
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
                                Text("\(total.formattedAmount) \( trip.primaryCurrency)")
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
            Section {
                if sortedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("尚無費用", systemImage: "receipt")
                    } description: {
                        Text("點擊右上角 + 新增費用")
                    }
                } else {
                    ForEach(sortedExpenses) { expense in
                        ExpenseRowView(expense: expense, trip: trip)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                expenseToEdit = expense
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    expenseToEdit = expense
                                } label: {
                                    Label("編輯", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .onDelete(perform: deleteExpenses)
                }
            } header: {
                Text("費用明細")
            } footer: {
                if !sortedExpenses.isEmpty {
                    Text("點擊費用可編輯，左滑刪除，右滑快速編輯")
                }
            }
        }
        .navigationTitle(trip.name.isEmpty ? "未命名行程" : trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditTrip = true }) {
                        Label("編輯行程", systemImage: "pencil")
                    }
                    Button(action: { showingAddExpense = true }) {
                        Label("新增費用", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(trip: trip)
        }
        .sheet(isPresented: $showingEditTrip) {
            EditTripView(trip: trip)
        }
        .sheet(item: $expenseToEdit) { expense in
            EditExpenseView(expense: expense)
        }
    }
       
        // 分類總計也要轉換貨幣
    private func totalForCategory(_ category: ExpenseCategory) -> Double {
        sortedExpenses
            .filter { $0.category == category }
            .reduce(0) { sum, expense in
                let convertedAmount = trip.convertToPrimaryCurrency(
                    amount: expense.amount,
                    from: expense.currency
                )
                return sum + convertedAmount
            }
    }
    
    private func deleteExpenses(at offsets: IndexSet) {
        let expensesToDelete = offsets.map { sortedExpenses[$0] }
        for expense in expensesToDelete {
            modelContext.delete(expense)
        }
    }
}

    // MARK: - Expense Row View
struct ExpenseRowView: View {
    let expense: Expense
    let trip: Trip
    
    var body: some View {
        HStack(spacing: 12) {
                // 分類圖示
            Text(expense.category.icon)
                .font(.title2)
            
                // 資訊
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(expense.storeName ?? "未知商家")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                        // ✅ 有收據照片時顯示圖示
                    if expense.receiptImage != nil {
                        Image(systemName: "paperclip")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                
                HStack(spacing: 4) {
                    Text(expense.category.displayName)
                    Text("·")
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
                // ✅ 金額（顯示原幣別和轉換金額）
            VStack(alignment: .trailing, spacing: 2) {
                    // 原幣別金額
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(expense.amount.formattedAmount)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(expense.currency)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                    // 轉換後的金額（如果不是主幣別）
                if expense.currency != trip.primaryCurrency {
                    let convertedAmount = trip.convertToPrimaryCurrency(
                        amount: expense.amount,
                        from: expense.currency
                    )
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.0f", convertedAmount))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(trip.primaryCurrency)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
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
        totalBudget: 500000,
        primaryCurrency: "JPY"
    )
    trip.exchangeRates["USD"] = 100
    container.mainContext.insert(trip)
    
    let expenses = [
        Expense(amount: 600, currency: "USD", date: Date(), storeName: "China Airlines", trip: trip, category: .transport),
        Expense(amount: 12000, currency: "JPY", date: Date(), storeName: "Shinjuku Hotel", trip: trip, category: .lodging),
        Expense(amount: 8000, currency: "JPY", date: Date().addingTimeInterval(-86400), storeName: "餐廳", trip: trip, category: .food),
    ]
    expenses.forEach { container.mainContext.insert($0) }
    
    return NavigationStack {
        TripDetailView(trip: trip)
    }
    .modelContainer(container)
}
