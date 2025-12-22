    //
    //  StatisticsView.swift - 修復版
    //  正確轉換貨幣和顯示幣別
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @Query private var expenses: [Expense]
    
        // 篩選狀態
    @State private var selectedTrip: Trip?
    
        // 篩選後的費用
    private var filteredExpenses: [Expense] {
        if let trip = selectedTrip {
            return trip.expenses ?? []
        }
        return expenses
    }
    
        // ✅ 修復 1：正確轉換貨幣的總支出
    private var totalAmount: Double {
        guard let trip = selectedTrip else {
                // 如果沒有選擇行程，計算所有費用（使用 TWD）
            return filteredExpenses.reduce(0) { $0 + $1.amount }
        }
        
            // 轉換成主幣後加總
        return filteredExpenses.reduce(0) { sum, expense in
            let exchangeRate = Double(trip.exchangeRates[expense.currency] ?? 1.0)
            let convertedAmount = expense.amount * exchangeRate
            return sum + convertedAmount
        }
    }
    
        // ✅ 獲取主幣貨幣代碼
    private var primaryCurrency: String {
        selectedTrip?.primaryCurrency ?? "TWD"
    }
    
        // 按分類統計（已轉換）
    private var categoryData: [(category: ExpenseCategory, amount: Double)] {
        guard let trip = selectedTrip else {
                // 如果沒選行程，用原始金額
            return ExpenseCategory.allCases.compactMap { category in
                let amount = filteredExpenses
                    .filter { $0.category == category }
                    .reduce(0) { $0 + $1.amount }
                return amount > 0 ? (category, amount) : nil
            }
        }
        
            // 轉換後的分類統計
        return ExpenseCategory.allCases.compactMap { category in
            let amount = filteredExpenses
                .filter { $0.category == category }
                .reduce(0) { sum, expense in
                    let exchangeRate = Double(trip.exchangeRates[expense.currency] ?? 1.0)
                    return sum + (expense.amount * exchangeRate)
                }
            return amount > 0 ? (category, amount) : nil
        }
    }
    
        // ✅ 每日分類支出資料（用於堆疊圖，已轉換）
    private var dailyCategoryData: [DailyExpense] {
        var result: [DailyExpense] = []
        
        guard let trip = selectedTrip else {
                // 如果沒選行程，用原始資料
            let grouped = Dictionary(grouping: filteredExpenses) { expense in
                Calendar.current.startOfDay(for: expense.date)
            }
            
            for (date, dayExpenses) in grouped {
                for category in ExpenseCategory.allCases {
                    let amount = dayExpenses
                        .filter { $0.category == category }
                        .reduce(0) { $0 + $1.amount }
                    if amount > 0 {
                        result.append(DailyExpense(date: date, category: category, amount: amount))
                    }
                }
            }
            return result.sorted { $0.date < $1.date }
        }
        
            // 轉換後的每日分類資料
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        
        for (date, dayExpenses) in grouped {
            for category in ExpenseCategory.allCases {
                let amount = dayExpenses
                    .filter { $0.category == category }
                    .reduce(0) { sum, expense in
                        let exchangeRate = Double(trip.exchangeRates[expense.currency] ?? 1.0)
                        return sum + (expense.amount * exchangeRate)
                    }
                if amount > 0 {
                    result.append(DailyExpense(date: date, category: category, amount: amount))
                }
            }
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        if trips.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "suitcase")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("沒有行程")
                    .font(.headline)
                
                Text("請先新增行程來開始記錄費用")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
        } else {
            ScrollView {
                VStack(spacing: 20) {
                        // MARK: - 行程篩選
                    tripPicker
                    
                        // MARK: - 總覽卡片
                    summaryCard
                    
                        // MARK: - 分類圖表
                    if !categoryData.isEmpty {
                        categoryChart
                    }
                    
                        // MARK: - 每日支出圖表（堆疊）
                    if !dailyCategoryData.isEmpty {
                        dailyStackedChart
                    }
                    
                        // MARK: - 分類明細
                    if !categoryData.isEmpty {
                        categoryDetail
                    }
                }
                .padding()
            }
            .navigationTitle("統計")
            .onAppear {
                    // ✅ 進入時自動選擇第一個行程
                if selectedTrip == nil && !trips.isEmpty {
                    selectedTrip = trips.first
                }
            }
        }
    }
    
        // MARK: - 行程篩選器
    private var tripPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("篩選行程")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !trips.isEmpty {
                Picker("選擇行程", selection: Binding(
                    get: { selectedTrip ?? trips.first },
                    set: { selectedTrip = $0 }
                )) {
                    ForEach(trips) { trip in
                        Text(trip.name.isEmpty ? "未命名行程" : trip.name)
                            .tag(trip as Trip?)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
        // MARK: - 總覽卡片
    private var summaryCard: some View {
        VStack(spacing: 12) {
            Text("總支出")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
                // ✅ 修復 2：顯示幣別
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(totalAmount.formattedAmount)")
                    .font(.system(size: 36, weight: .bold))
                Text(primaryCurrency)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            Text("共 \(filteredExpenses.count) 筆費用")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
        // MARK: - 分類圓餅圖
    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分類佔比")
                .font(.headline)
            
            Chart(categoryData, id: \.category) { item in
                SectorMark(
                    angle: .value("金額", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            
                // ✅ 圖例
            legendView
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
        // ✅ 圖例
    private var legendView: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
            ForEach(categoryData, id: \.category) { item in
                HStack(spacing: 4) {
                    Circle()
                        .fill(item.category.color)
                        .frame(width: 10, height: 10)
                    Text(item.category.displayName)
                        .font(.caption)
                }
            }
        }
    }
    
        // ✅ 每日支出堆疊長條圖
    private var dailyStackedChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每日支出")
                .font(.headline)
            
            Chart(dailyCategoryData) { item in
                BarMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("金額", item.amount)
                )
                .foregroundStyle(by: .value("分類", item.category.displayName))
                .cornerRadius(4)
            }
            .chartForegroundStyleScale(
                domain: ExpenseCategory.allCases.map { $0.displayName },
                range: ExpenseCategory.allCases.map { $0.color }
            )
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day(), centered: true)
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
        // ✅ 分類顏色對應
    private var categoryColorMapping: KeyValuePairs<String, Color> {
        return [
            ExpenseCategory.transport.displayName: ExpenseCategory.transport.color,
            ExpenseCategory.lodging.displayName: ExpenseCategory.lodging.color,
            ExpenseCategory.food.displayName: ExpenseCategory.food.color,
            ExpenseCategory.telecom.displayName: ExpenseCategory.telecom.color,
            ExpenseCategory.miscellaneous.displayName: ExpenseCategory.miscellaneous.color
        ]
    }
    
        // MARK: - 分類明細列表
    private var categoryDetail: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分類明細")
                .font(.headline)
            
            ForEach(categoryData, id: \.category) { item in
                HStack {
                        // ✅ 顏色圓點 + 圖示 + 名稱
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.category.color)
                            .frame(width: 12, height: 12)
                        Text(item.category.icon)
                        Text(item.category.displayName)
                    }
                    
                    Spacer()
                    
                        // ✅ 分類明細也顯示幣別
                    Text("\(item.amount.formattedAmount)  \(primaryCurrency)")
                        .fontWeight(.medium)
                    
                    Text(formatPercentage(item.amount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
                .padding(.vertical, 8)
                
                if item.category != categoryData.last?.category {
                    Divider()
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
       
    private func formatPercentage(_ value: Double) -> String {
        guard totalAmount > 0 else { return "0%" }
        let percentage = (value / totalAmount) * 100
        return String(format: "%.0f%%", percentage)
    }
}

    // ✅ 每日分類支出資料結構
struct DailyExpense: Identifiable {
    let id = UUID()
    let date: Date
    let category: ExpenseCategory
    let amount: Double
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
    let trip = Trip(
        name: "東京出差",
        destination: "東京",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 5)
    )
        // ✅ 設置匯率
    trip.exchangeRates["USD"] = 100
    trip.primaryCurrency = "JPY"
    
    container.mainContext.insert(trip)
    
    let expenses = [
        Expense(amount: 600, currency: "USD", date: Date(), storeName: "China Airlines", trip: trip, category: .transport),
        Expense(amount: 12000, currency: "JPY", date: Date(), storeName: "Shinjuku Hotel", trip: trip, category: .lodging),
        Expense(amount: 8000, currency: "JPY", date: Date().addingTimeInterval(-86400), storeName: "餐廳", trip: trip, category: .food),
    ]
    expenses.forEach { container.mainContext.insert($0) }
    
    return NavigationStack {
        StatisticsView()
    }
    .modelContainer(container)
}
