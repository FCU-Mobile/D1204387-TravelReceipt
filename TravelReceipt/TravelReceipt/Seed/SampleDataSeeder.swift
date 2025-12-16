    // Seed/SampleDataSeeder.swift
import Foundation
import SwiftData
import SwiftDate

struct SampleDataSeeder {
    static func seedIfNeeded(context: ModelContext) {
            // 1. 檢查是否已有 Trip 資料，有就跳過 (避免重複產生)
        let descriptor = FetchDescriptor<Trip>()
        if let count = try? context.fetchCount(descriptor), count > 0 {
            return
        }
        
            // 2. 建立日期 (使用原生 Calendar)
        let calendar = Calendar.current
            // 設定 2025-12-01 為開始日
        let startComponents = DateComponents(year: 2025, month: 12, day: 1)
        guard let start = calendar.date(from: startComponents) else { return }
        
            // 設定 2025-12-05 為結束日
        let endComponents = DateComponents(year: 2025, month: 12, day: 5)
        guard let end = calendar.date(from: endComponents) else { return }
        
            // 3. 建立 Trip (使用 Double 型別)
        let trip = Trip(
            name: "出差收據通|上海差旅(2025/12)",
            destination: "上海",
            startDate: start,
            endDate: end,
            totalBudget: 50000.0, // Double
            notes: "範例資料"
        )
        context.insert(trip)
        
            // 4. 建立支出 (Expense)
        
            // 第一筆：交通
        let r1 = Expense(
            amount: 350.0,
            currency: "CNY",
            date: start,
            storeName: "浦東機場地鐵",
            notes: "機場→市區",
            trip: trip,
            category: .transport
        )
        
            // 第二筆：餐飲 (日期+1天)
        let day2 = start + 1.days
        let r2 = Expense(
            amount: 980.0,
            currency: "CNY",
            date: day2,
            storeName: "商務午餐",
            trip: trip,
            category: .food
        )
        
            // 第三筆：住宿 (日期+2天)
        let day3 = start + 2.days
        let r3 = Expense(
            amount: 2100.0,
            currency: "CNY",
            date: day3,
            storeName: "商旅飯店",
            notes: "2晚",
            trip: trip,
            category: .lodging
        )
        
            // 第四筆：通訊
        let r4 = Expense(
            amount: 120.0,
            currency: "CNY",
            date: day3,
            storeName: "數據漫遊",
            trip: trip,
            category: .telecom
        )
        
        [r1, r2, r3, r4].forEach { context.insert($0) }
        
            // 6. 存檔
        do {
            try context.save()
            print("✅ 種子資料建立成功！")
        } catch {
            print("❌ Seed save error: \(error)")
        }
    }
}
