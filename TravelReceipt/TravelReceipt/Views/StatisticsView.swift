    //
    //  StatisticsView.swift
    //  TravelReceipt
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
    @State private var selectedTrip: Trip? = nil
    
        // 篩選後的費用
    private var filteredExpenses: [Expense] {
        if let trip = selectedTrip {
            return trip.expenses ?? []
        }
        return expenses
    }
    
        // 總支出
    private var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
        // 按分類統計
    private var categoryData: [(category: ExpenseCategory, amount: Double)] {
        ExpenseCategory.allCases.compactMap { category in
            let amount = filteredExpenses
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
            return amount > 0 ? (category, amount) : nil
        }
    }
    
        // 按日期統計（每日支出）
    private var dailyData: [(date: Date, amount: Double)] {
        let grouped = Dictionary(grouping: filteredExpenses) { expense in
            Calendar.current.startOfDay(for: expense.date)
        }
        return grouped.map { (date: $0.key, amount: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
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
                
                    // MARK: - 每日支出圖表
                if !dailyData.isEmpty {
                    dailyChart
                }
                
                    // MARK: - 分類明細
                if !categoryData.isEmpty {
                    categoryDetail
                }
            }
            .padding()
        }
        .navigationTitle("統計")
    }
    
        // MARK: - 行程篩選器
    private var tripPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("篩選行程")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Picker("選擇行程", selection: $selectedTrip) {
                Text("全部行程").tag(nil as Trip?)
                ForEach(trips) { trip in
                    Text(trip.name.isEmpty ? "未命名行程" : trip.name).tag(trip as Trip?)
                }
            }
            .pickerStyle(.menu)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
        // MARK: - 總覽卡片
    private var summaryCard: some View {
        VStack(spacing: 12) {
            Text("總支出")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(formatAmount(totalAmount) + " 元")
                .font(.system(size: 36, weight: .bold))
            
            Text("共 \(filteredExpenses.count) 筆費用")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemGray6))
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
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
        // MARK: - 每日支出長條圖
    private var dailyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每日支出")
                .font(.headline)
            
            Chart(dailyData, id: \.date) { item in
                BarMark(
                    x: .value("日期", item.date, unit: .day),
                    y: .value("金額", item.amount)
                )
                .foregroundStyle(.blue.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day(), centered: true)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
        // MARK: - 分類明細列表
    private var categoryDetail: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分類明細")
                .font(.headline)
            
            ForEach(categoryData, id: \.category) { item in
                HStack {
                    HStack(spacing: 8) {
                        Text(item.category.icon)
                        Text(item.category.displayName)
                    }
                    
                    Spacer()
                    
                    Text(formatAmount(item.amount) + " 元")
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
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
        // MARK: - Helper Methods
    private func formatAmount(_ value: Double) -> String {
        String(format: "%.0f", value)
    }
    
    private func formatPercentage(_ value: Double) -> String {
        guard totalAmount > 0 else { return "0%" }
        let percentage = (value / totalAmount) * 100
        return String(format: "%.0f%%", percentage)
    }
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
        // 建立測試資料
    let trip = Trip(
        name: "東京出差",
        destination: "東京",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 5)
    )
    container.mainContext.insert(trip)
    
    let expenses = [
        Expense(amount: 3500, currency: "TWD", date: Date(), storeName: "高鐵", trip: trip, category: .transport),
        Expense(amount: 1200, currency: "TWD", date: Date(), storeName: "午餐", trip: trip, category: .food),
        Expense(amount: 4500, currency: "TWD", date: Date().addingTimeInterval(-86400), storeName: "飯店", trip: trip, category: .lodging),
        Expense(amount: 300, currency: "TWD", date: Date().addingTimeInterval(-86400), storeName: "漫遊", trip: trip, category: .telecom)
    ]
    expenses.forEach { container.mainContext.insert($0) }
    
    return NavigationStack {
        StatisticsView()
    }
    .modelContainer(container)
}
