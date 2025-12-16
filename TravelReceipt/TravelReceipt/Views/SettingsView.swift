    //
    //  SettingsView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @Query private var expenses: [Expense]
    
        // 狀態
    @State private var defaultCurrency: String = "TWD"
    @State private var showingDeleteAlert = false
    @State private var showingExportSheet = false
    @State private var exportMessage: String = ""
    
        // 常用貨幣
    private let currencies = ["TWD", "CNY", "JPY", "USD", "EUR", "HKD", "KRW"]
    
    var body: some View {
        List {
                // MARK: - 一般設定
            Section("一般設定") {
                Picker("預設貨幣", selection: $defaultCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
            }
            
                // MARK: - 資料統計
            Section("資料統計") {
                LabeledContent("行程數量", value: "\(trips.count) 筆")
                LabeledContent("費用數量", value: "\(expenses.count) 筆")
                LabeledContent("總支出", value: formatAmount(totalExpenses) + " 元")
            }
            
                // MARK: - 資料管理
            Section {
                Button(action: { showingExportSheet = true }) {
                    Label("匯出 CSV", systemImage: "square.and.arrow.up")
                }
                
                Button(action: seedSampleData) {
                    Label("載入範例資料", systemImage: "tray.and.arrow.down")
                }
                
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("清除所有資料", systemImage: "trash")
                }
            } header: {
                Text("資料管理")
            } footer: {
                Text("清除後無法復原，請謹慎操作")
            }
            
                // MARK: - 關於
            Section("關於") {
                LabeledContent("版本", value: "1.0.0")
                LabeledContent("開發者", value: "YiJou")
                
                Link(destination: URL(string: "https://github.com")!) {
                    HStack {
                        Text("GitHub")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("設定")
        .alert("確認清除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("確定要清除所有行程和費用資料嗎？此操作無法復原。")
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(expenses: expenses)
        }
    }
    
        // MARK: - Computed Properties
    private var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
        // MARK: - Methods
    private func formatAmount(_ value: Double) -> String {
        String(format: "%.0f", value)
    }
    
    private func deleteAllData() {
            // 先刪除費用
        for expense in expenses {
            modelContext.delete(expense)
        }
            // 再刪除行程
        for trip in trips {
            modelContext.delete(trip)
        }
    }
    
    private func seedSampleData() {
        SampleDataSeeder.seedIfNeeded(context: modelContext)
    }
}

    // MARK: - Export View
struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    let expenses: [Expense]
    
    @State private var exportResult: String = ""
    @State private var showingShareSheet = false
    @State private var csvURL: URL? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("匯出費用資料")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("將 \(expenses.count) 筆費用匯出為 CSV 格式")
                    .foregroundStyle(.secondary)
                
                if !exportResult.isEmpty {
                    Text(exportResult)
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding()
                }
                
                Button(action: exportCSV) {
                    Label("產生 CSV", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("匯出")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("關閉") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = csvURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func exportCSV() {
            // CSV 標頭
        var csv = "日期,分類,商家,金額,貨幣,行程,備註\n"
        
            // 資料列
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for expense in expenses.sorted(by: { $0.date < $1.date }) {
            let date = dateFormatter.string(from: expense.date)
            let category = expense.category.displayName
            let store = expense.storeName ?? ""
            let amount = String(format: "%.0f", expense.amount)
            let currency = expense.currency ?? "TWD"
            let tripName = expense.trip?.name ?? ""
            let notes = expense.notes ?? ""
            
            csv += "\(date),\(category),\(store),\(amount),\(currency),\(tripName),\(notes)\n"
        }
        
            // 儲存到暫存目錄
        let fileName = "TravelReceipt_\(Date().formatted(.dateTime.year().month().day())).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            csvURL = tempURL
            showingShareSheet = true
            exportResult = "✅ CSV 已產生"
        } catch {
            exportResult = "❌ 匯出失敗：\(error.localizedDescription)"
        }
    }
}

    // MARK: - Share Sheet (UIKit Bridge)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

    // MARK: - Preview
#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Trip.self, Expense.self], inMemory: true)
}
