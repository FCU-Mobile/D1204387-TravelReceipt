import Foundation

    // MARK: - String 正規化擴展
extension String {
        /// 正規化字符串（去空格、統一格式等）
    func normalized() -> String {
            // 去除前後空格和換行
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
            // 替換多個連續空格為單個空格
        let normalized = trimmed.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        
        return normalized
    }
    
        /// 提取數字
    func extractNumbers() -> String {
        return self.filter { $0.isNumber }
    }
    
        /// 提取金額（支持小數點和逗號）
    func extractAmount() -> Double? {
        let pattern = "[0-9]+[.,][0-9]{1,2}|[0-9]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        let range = NSRange(self.startIndex..., in: self)
        guard let match = regex.firstMatch(in: self, range: range) else {
            return nil
        }
        
        let matchString = (self as NSString).substring(with: match.range)
        let cleanString = matchString.replacingOccurrences(of: ",", with: "")
        
        return Double(cleanString)
    }
    
        /// 移除特殊字符
    func removeSpecialCharacters() -> String {
        return self.replacingOccurrences(
            of: "[^a-zA-Z0-9\\u4e00-\\u9fff\\s]",
            with: "",
            options: .regularExpression
        )
    }
    
        /// 檢查是否為空或只有空格
    var isEmptyOrWhitespace: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

