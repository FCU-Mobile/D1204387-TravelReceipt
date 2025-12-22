//
//  ReceiptPhotoManager.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/22.
//

import Foundation
import UIKit
import Observation

@Observable
final class ReceiptPhotoManager {
    var receiptImage: UIImage? = nil
    var receiptImageData: Data? = nil
    
    func setImage(_ image: UIImage) {
        self.receiptImage = image
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            self.receiptImageData = imageData
            print("📸 照片已保存: \(imageData.count) bytes")
        }
    }
    
    func clearImage() {
        self.receiptImage = nil
        self.receiptImageData = nil
        print("🗑️ 照片已清除")
    }
}
