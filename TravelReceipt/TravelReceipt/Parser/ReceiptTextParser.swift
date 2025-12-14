//
//  ReceiptTextParser.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/14.
//

import Foundation

struct ReceiptTextParser {
    struct ParseResult {
        var date: Date?
        var totalAmount: Decimal?
        var merchantName: String?
        var items: [ParsedItem] = []
        var currencyCode: String = "TWD"
    }
    
    static func parse(rawText: String) -> ParseResult {
        var res = ParseResult()
        
            // 1. 拆解成行
        let lines = rawText.components(separatedBy: .newlines)
        
            // 2. 嘗試抓取商家名稱 (通常在第一行)
        res.merchantName = matchMerchant(in: lines)
        
            // 3. 抓取日期
        res.date = parseDate(s: matchDate(in: rawText))
        
            // 4. 抓取總金額
        res.totalAmount = matchAmount(in: rawText)
        
            // 5. (進階) 這裡可以加入更複雜的品項分析邏輯，目前先留空
        
        return res
    }
    
        // MARK: - Helpers
    
    private static func matchMerchant(in lines: [String]) -> String? {
            // 取第一行若長度適中當作標題
        if let first = lines.first, first.count > 0 && first.count <= 40 { return first }
        return nil
    }
    
    private static func matchDate(in text: String) -> String? {
            // 匹配 yyyy-MM-dd 或 yyyy/MM/dd
        let patterns = [
            #"\b(20\d{2})[-/.](0[1-9]|1[0-2])[-/.](0[1-9]|[12]\d|3[01])\b"#,
            #"(20\d{2})年(0?[1-9]|1[0-2])月(0?[1-9]|[12]\d|3[01])日"#
        ]
        
        for p in patterns {
            if let r = try? NSRegularExpression(pattern: p),
               let m = r.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                return String(text[Range(m.range, in: text)!])
            }
        }
        return nil
    }
    
    private static func parseDate(s: String?) -> Date? {
        guard let s = s else { return nil }
        let fmts = ["yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd", "yyyy年MM月dd日"]
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_TW")
        for f in fmts {
            df.dateFormat = f
            if let d = df.date(from: s) { return d }
        }
        return nil
    }
    
    private static func matchAmount(in text: String) -> Decimal? {
            // 簡單策略：找含有「總計、金額、Total」的行，若無則搜全篇，找最大的數字
        let keywordLines = text.components(separatedBy: .newlines).filter {
            $0.localizedCaseInsensitiveContains("總計") ||
            $0.localizedCaseInsensitiveContains("金額") ||
            $0.localizedCaseInsensitiveContains("Total") ||
            $0.localizedCaseInsensitiveContains("Amount")
        }
        
        let targetText = keywordLines.isEmpty ? text : keywordLines.joined(separator: "\n")
        
            // 匹配金額數字 (支援 1,000.00 格式)
        let pattern = #"(?<!\d)(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)"#
        
        guard let r = try? NSRegularExpression(pattern: pattern) else { return nil }
        let matches = r.matches(in: targetText, range: NSRange(targetText.startIndex..., in: targetText))
        
        let amounts = matches.map {
            String(targetText[Range($0.range, in: targetText)!]).replacingOccurrences(of: ",", with: "")
        }.compactMap { Decimal(string: $0) }
        
        return amounts.max() // 假設最大的數字是總額
    }
}
