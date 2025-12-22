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
    @State private var showingSeedAlert = false
    @State private var seedAlertMessage = ""
    @State private var seedNeedsConfirm = false
    
        // 常用貨幣
    private let currencies = Constants.Currency.all
    
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
                
                if trips.isEmpty {
                    Text("無行程")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(trips) { trip in
                        let tripTotal = trip.totalExpensesInPrimaryCurrency
                        LabeledContent(
                            trip.name.isEmpty ? "未命名行程" : trip.name,
                            value: "\(tripTotal.formattedAmount) \(trip.primaryCurrency)"
                        )
                    }
                }
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
        }
        .navigationTitle("設定")
            // 清除資料 Alert
        .alert("確認清除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("確定要清除所有行程和費用資料嗎？此操作無法復原。")
        }
            // 載入範例 Alert
        .alert("載入範例資料", isPresented: $showingSeedAlert) {
            if seedNeedsConfirm {
                Button("取消", role: .cancel) { }
                Button("新增") {
                    performSeed()
                }
            } else {
                Button("確定", role: .cancel) { }
            }
        } message: {
            Text(seedAlertMessage)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(expenses: expenses)
        }
    }
    
    private func deleteAllData() {
        for expense in expenses {
            modelContext.delete(expense)
        }
        for trip in trips {
            modelContext.delete(trip)
        }
    }
    
    private func seedSampleData() {
        if !trips.isEmpty {
            seedAlertMessage = "已有 \(trips.count) 筆行程，是否仍要新增範例資料？"
            seedNeedsConfirm = true
            showingSeedAlert = true
        } else {
            performSeed()
        }
    }
    
    private func performSeed() {
        _ = SampleDataSeeder.seedSampleData(context: modelContext)
        seedAlertMessage = "✅ 範例資料已載入"
        seedNeedsConfirm = false
        showingSeedAlert = true
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
                        .background(.blue)
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
        var csv = "日期,分類,商家,金額,貨幣,行程,備註\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for expense in expenses.sorted(by: { $0.date < $1.date }) {
            let date = dateFormatter.string(from: expense.date)
            let category = expense.category.displayName
            let store = expense.storeName ?? ""
            let amount = String(format: "%.0f", expense.amount)
            let currency = expense.currency
            let tripName = expense.trip?.name ?? ""
            let notes = expense.notes ?? ""
            
            csv += "\(date),\(category),\(store),\(amount),\(currency),\(tripName),\(notes)\n"
        }
        
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

    // MARK: - Share Sheet
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
