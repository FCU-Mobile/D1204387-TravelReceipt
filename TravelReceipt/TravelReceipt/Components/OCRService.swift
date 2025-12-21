//
//  OCRService.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/17.
//

import Foundation
import Vision
import UIKit

struct OCRResult {
    var amount: Double?
    var date: Date?
    var storeName: String?
    var rawText: String
}

class OCRService {
    
    static func recognizeText(from image: UIImage, completion: @escaping (OCRResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(OCRResult(rawText: ""))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(OCRResult(rawText: ""))
                return
            }
            
                // 收集所有辨識到的文字
            var allTexts: [(text: String, y: CGFloat)] = []
            
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    allTexts.append((topCandidate.string, observation.boundingBox.origin.y))
                }
            }
            
                // 按 Y 座標排序（從上到下，注意 Vision 的座標是從下往上）
            allTexts.sort { $0.y > $1.y }
            
            let rawText = allTexts.map { $0.text }.joined(separator: "\n")
            
                // 解析結果
            let amount = parseAmount(from: rawText)
            let date = parseDate(from: rawText)
            let storeName = parseStoreName(from: allTexts.map { $0.text })
            
            DispatchQueue.main.async {
                completion(OCRResult(
                    amount: amount,
                    date: date,
                    storeName: storeName,
                    rawText: rawText
                ))
            }
        }
        
            // 設定辨識語言（繁體中文 + 英文）
        request.recognitionLanguages = ["zh-Hant", "zh-Hans", "en-US"]
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ OCR 錯誤: \(error)")
                DispatchQueue.main.async {
                    completion(OCRResult(rawText: ""))
                }
            }
        }
    }
    
        // MARK: - 解析金額
    private static func parseAmount(from text: String) -> Double? {
            // 常見金額格式
        let patterns = [
            #"總[計額]\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,      // 總計: $123 或 總額：123
            #"合\s*計\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,       // 合計: 123
            #"金\s*額\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,       // 金額: 123
            #"NT\$?\s*([\d,]+\.?\d*)"#,                        // NT$123 或 NT 123
            #"TWD\s*([\d,]+\.?\d*)"#,                          // TWD 123
            #"實付\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,          // 實付: 123
            #"應付\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,          // 應付: 123
            #"小\s*計\s*[:：]?\s*\$?\s*([\d,]+\.?\d*)"#,       // 小計: 123
            #"\$\s*([\d,]+\.?\d*)"#,                           // $123
            #"([\d,]+)\s*元"#,                                 // 123元
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let amountRange = Range(match.range(at: 1), in: text) {
                        let amountStr = String(text[amountRange]).replacingOccurrences(of: ",", with: "")
                        if let amount = Double(amountStr), amount > 0 && amount < 1000000 {
                            return amount
                        }
                    }
                }
            }
        }
        
            // 最後嘗試：找最大的合理數字
        let numberPattern = #"([\d,]+\.?\d*)"#
        if let regex = try? NSRegularExpression(pattern: numberPattern, options: []) {
            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, options: [], range: range)
            
            var amounts: [Double] = []
            for match in matches {
                if let numRange = Range(match.range(at: 1), in: text) {
                    let numStr = String(text[numRange]).replacingOccurrences(of: ",", with: "")
                    if let num = Double(numStr), num > 10 && num < 100000 {
                        amounts.append(num)
                    }
                }
            }
            
                // 回傳最大的金額（通常是總額）
            return amounts.max()
        }
        
        return nil
    }
    
        // MARK: - 解析日期
    private static func parseDate(from text: String) -> Date? {
        let patterns = [
            (#"(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})"#, "yyyy-MM-dd"),  // 2025/12/17
            (#"(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})"#, "MM-dd-yyyy"),  // 12/17/2025
            (#"(\d{3})[/\-.](\d{1,2})[/\-.](\d{1,2})"#, "yyy-MM-dd"),   // 114/12/17 (民國年)
        ]
        
        for (pattern, _) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    var components: [Int] = []
                    for i in 1...3 {
                        if let r = Range(match.range(at: i), in: text),
                           let num = Int(text[r]) {
                            components.append(num)
                        }
                    }
                    
                    if components.count == 3 {
                        var year = components[0]
                        var month = components[1]
                        var day = components[2]
                        
                            // 處理民國年
                        if year < 200 {
                            year += 1911
                        }
                        
                            // 驗證日期合理性
                        if month > 12 {
                            swap(&month, &day)
                        }
                        
                        var dateComponents = DateComponents()
                        dateComponents.year = year
                        dateComponents.month = month
                        dateComponents.day = day
                        
                        if let date = Calendar.current.date(from: dateComponents) {
                            return date
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
        // MARK: - 解析商家名稱
    private static func parseStoreName(from lines: [String]) -> String? {
            // 過濾掉不太可能是店名的行
        let filtered = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
                // 排除條件
            if trimmed.count < 2 || trimmed.count > 30 { return false }
            if trimmed.contains("統一編號") { return false }
            if trimmed.contains("發票") { return false }
            if trimmed.contains("日期") { return false }
            if trimmed.contains("時間") { return false }
            if trimmed.contains("金額") { return false }
            if trimmed.contains("總計") { return false }
            if trimmed.contains("合計") { return false }
            if trimmed.contains("小計") { return false }
            if trimmed.contains("找零") { return false }
            if trimmed.contains("現金") { return false }
            if trimmed.contains("信用卡") { return false }
            if trimmed.allSatisfy({ $0.isNumber || $0 == "." || $0 == "," || $0 == "-" }) { return false }
            
            return true
        }
        
            // 回傳第一行（通常是店名）
        return filtered.first?.trimmingCharacters(in: .whitespaces)
    }
}
