//
//  NotesFormatter.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/14.
//

import Foundation

struct NotesFormatter {
        /// 將 OCR 解析出的品項轉成 notes 字串 (例: 1x Pink Drink @ 40.00)
    static func itemsToNotes(items: [ParsedItem], currencyCode: String? = nil) -> String {
        guard !items.isEmpty else { return "" }
        let symbol = currencySymbol(for: currencyCode)
        
        let lines = items.map { it in
            let price = NSDecimalNumber(decimal: it.unitPrice).doubleValue
            return "\(it.qty)x \(it.name) @ \(symbol)\(String(format: "%.2f", price))"
        }
        return lines.joined(separator: "; ")
    }
    
        /// 將台灣電子發票 QR 的重點欄位寫入 notes
    static func twInvoiceToNotes(invoiceNumber: String?, sellerVAT: String?, date: Date?, totalAmount: Decimal?, extra: [String] = []) -> String {
        var parts: [String] = []
        if let inv = invoiceNumber { parts.append("發票號:\(inv)") }
        if let vat = sellerVAT { parts.append("統編:\(vat)") }
        
        if let d = date {
            let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
            parts.append("日期:\(df.string(from: d))")
        }
        
        if let t = totalAmount {
            let n = NSDecimalNumber(decimal: t).doubleValue
            parts.append("總額:\(String(format: "%.2f", n))")
        }
        
        parts.append(contentsOf: extra.filter { !$0.isEmpty })
        return parts.joined(separator: " | ")
    }
    
    private static func currencySymbol(for code: String?) -> String {
        switch (code ?? "").uppercased() {
        case "TWD": return "NT$"
        case "CNY": return "¥"
        case "USD": return "$"
        case "EUR": return "€"
        case "JPY": return "¥"
        default: return "$"
        }
    }
}
