//
//  Expense.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/13.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var currency: String
    var date: Date
    var notes: String? = nil
    
    // === 憑證相關 ===
    var receiptImage: Data? = nil // 儲存憑證圖片的二進位資料
    var storeName: String? = nil
    var itemName: String? = nil
    var itemQuantity: Int? = nil
    
    // === AI辨識狀態 ===
    var isAIProcessed: Bool = false // 是否已經進行AI辨識
    var aiDetectionDate: Date? = nil // AI辨識的日期時間
    var isManuallyVerified: Bool = false // 使用者是否手動修正過AI辨識結果
    
    // === 關聯 ===
    @Relationship(deleteRule: .nullify)
    var trip: Trip?
    
    var category: String? = nil
    
    // === 計算屬性 ===
    var isReadyToSave: Bool {
        return isAIProcessed && isManuallyVerified && amount > 0
    }
    
    init(amount: Double, currency: String = "TWD", date: Date, storeName: String? = nil, itemName: String? = nil, itemQuantity: Int? = nil, notes: String? = nil, receiptImage: Data? = nil, trip: Trip? = nil, category: String? = nil) {
        self.amount = amount
        self.currency = currency
        self.date = date
        self.storeName = storeName
        self.itemName = itemName
        self.itemQuantity = itemQuantity
        self.notes = notes
        self.receiptImage = receiptImage
        self.trip = trip
        self.category = category
    }
}
