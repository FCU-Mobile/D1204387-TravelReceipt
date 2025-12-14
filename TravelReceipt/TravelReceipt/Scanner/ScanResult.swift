//
//  ScanResult.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/14.
//

import Foundation

struct ParsedItem: Codable {
    var name: String
    var qty: Int = 1
    var unitPrice: Decimal = 0
}

struct ScanResult {
    var date: Date?
    var amount: Decimal?
    var merchantName: String?
    var eInvoiceNumber: String?
    var sellerVAT: String?
    var qrRaw: String? // 原始 QR payload（存證/除錯）
    
        // 🆕 供 OCR 解析用
    var rawText: String?
    var items: [ParsedItem] = []
}
