//
//  ReceiptScannerView.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/14.
//

import SwiftUI
import VisionKit
import Vision

struct ReceiptScannerView: UIViewControllerRepresentable {
    typealias Completion = (ScanResult) -> Void
    let onComplete: Completion
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {

        Coordinator(onComplete: onComplete, onCancel: onCancel)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onComplete: Completion
        let onCancel: () -> Void
        
        init(onComplete: @escaping Completion, onCancel: @escaping () -> Void) {
            self.onComplete = onComplete
            self.onCancel = onCancel
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true) { self.onCancel() }
                return
            }
                // 取第一頁影像進行 OCR
            let img = scan.imageOfPage(at: 0)
            performOCR(image: img) { result in
                controller.dismiss(animated: true) { self.onComplete(result) }
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true) { self.onCancel() }
        }
        
            // Scanner/ReceiptScannerView.swift（節錄：Coordinator.performOCR）
        private func performOCR(image: UIImage, completion: @escaping (ScanResult) -> Void) {
            guard let cgImage = image.cgImage else { completion(ScanResult()); return }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            let request = VNRecognizeTextRequest { req, _ in
                var scanRes = ScanResult()
                guard let observations = req.results as? [VNRecognizedTextObservation] else {
                    completion(scanRes); return
                }
                
                let lines: [String] = observations.compactMap { $0.topCandidates(1).first?.string }
                let joined = lines.joined(separator: "\n")
                
                    // ✅ 解析整張 OCR 文本
                let parsed = ReceiptTextParser.parse(rawText: joined)
                
                    // 以總額為主
                scanRes.date = parsed.date
                scanRes.amount = parsed.totalAmount
                scanRes.merchantName = parsed.merchantName
                scanRes.qrRaw = nil
                
                scanRes.rawText = joined
                scanRes.items = parsed.items     // 👉 新增：把 items 帶回 UI
                
                completion(scanRes)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.customWords = ["發票","統編","金額","總計","收據","公司","店名","小計","付款","Change","Due"]
            try? requestHandler.perform([request])
        }
        
        
            // MARK: - Helpers
        static func matchDate(in text: String) -> String? {
            let patterns = [
                #"\b(20\d{2})00[1-9]|[12]\d|3[01]\b"#,         // yyyy-MM-dd
                #"(20\d{2})年(0?[1-9]|1[0-2])月(0?[1-9]|[12]\d|3[01])日"#                 // yyyy年MM月dd日
            ]
            for p in patterns {
                if let r = try? NSRegularExpression(pattern: p),
                   let m = r.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                    return String(text[Range(m.range, in: text)!])
                }
            }
            return nil
        }
        
        static func parseDate(_ s: String) -> Date? {
                // 嘗試多種格式
            let fmts = ["yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd", "yyyy年MM月dd日"]
            let df = DateFormatter()
            df.locale = Locale(identifier: "zh_TW")
            for f in fmts {
                df.dateFormat = f
                if let d = df.date(from: s) { return d }
            }
            return nil
        }
        
        static func matchAmount(in text: String) -> Decimal? {
                // 先找包含關鍵字的行，抓最大數字作為總額
            let keywordLines = text
                .components(separatedBy: .newlines)
                .filter { $0.localizedCaseInsensitiveContains("總計") ||
                    $0.localizedCaseInsensitiveContains("金額") ||
                    $0.localizedCaseInsensitiveContains("Amount") ||
                    $0.localizedCaseInsensitiveContains("Total") }
            let target = keywordLines.isEmpty ? text : keywordLines.joined(separator: "\n")
            let pattern = #"(?<!\d)(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)"#
            guard let r = try? NSRegularExpression(pattern: pattern) else { return nil }
            let matches = r.matches(in: target, range: NSRange(target.startIndex..., in: target))
            let nums = matches.compactMap { Range($0.range(at: 1), in: target) }
                .map { target[$0].replacingOccurrences(of: ",", with: "") }
                .compactMap { Decimal(string: $0) }
            return nums.max()
        }
        
        static func matchMerchant(in lines: [String]) -> String? {
                // 取第一行若像標題；或找含「商店/店名/公司/商家」關鍵詞
            if let first = lines.first, first.count <= 40 { return first }
            let keys = ["商店", "店名", "公司", "商家", "Merchant", "Company"]
            for l in lines {
                if keys.contains(where: { l.contains($0) }) { return l }
            }
            return nil
        }
    }
}

#Preview {
    ReceiptScannerView(onComplete: { result in
        print("預覽模式：掃描完成，結果為 \(result)")
    },
                       onCancel: {
        print("預覽模式：取消掃描")
    })
}
