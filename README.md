# TravelReceipt - 出差費用記帳應用

## 📌 概述

一個簡單的 iOS 應用，用於記錄和管理個人出差期間的費用開支。用戶可以建立出差行程、添加費用、查看統計圖表，並透過 CloudKit 進行多設備同步。

## 🎯 主要功能

- ✅ 建立和管理出差行程
- ✅ 添加和分類費用（交通、住宿、餐飲、雜支）
- ✅ 查看費用統計圖表（圓餅圖）
- ✅ 拍照保存費用憑證
- ✅ CloudKit 多設備同步
- ✅ 刪除出差時自動刪除相關費用

## 🔧 技術

| 技術 | 用途 |
|------|------|
| SwiftUI | UI 框架 |
| SwiftData | 本地數據存儲 |
| CloudKit | 多設備同步 |
| SwiftCharts | 統計圖表 |
| PhotosUI | 照片選取 |

**為什麼這些選擇？**
- SwiftUI：iOS 17+ 推薦，代碼簡潔
- SwiftData：比 CoreData 更易用
- CloudKit：無需後端，免費同步
- MVVM 架構：職責清晰，易於測試

## 📁 項目結構

```
TravelReceipt/
├── Models/              # 數據模型
│   ├── Trip.swift
│   ├── Expense.swift
│   └── ExpenseCategory.swift
├── ViewModels/          # 業務邏輯
├── Views/               # UI 視圖
├── Services/            # 數據服務
└── TravelReceiptApp.swift
```

## 📋 數據模型

**Trip（出差行程）**
- id, name, startDate, endDate, location
- expenses（相關費用列表）
- 計算屬性：tripDays（天數）、totalExpense（總費用）

**Expense（費用單據）**
- id, amount, category, description, date
- receiptImage（憑證圖片）
- trip（關聯的出差）

**ExpenseCategory（分類）**
- transport（交通）
- accommodation（住宿）
- food（餐飲）
- miscellaneous（雜支）

## 🚀 如何使用

1. 克隆項目
   ```bash
   git clone https://github.com/yourname/TravelReceipt.git
   ```

2. 用 Xcode 打開
   ```bash
   open TravelReceipt.xcodeproj
   ```

3. 配置 CloudKit
   - 選擇項目 → Signing & Capabilities
   - 點擊「+ Capability」→ iCloud
   - 勾選 CloudKit

4. 運行
   - 選擇 iOS 17+ 模擬器
   - 按 Cmd + R 運行

## 💻 功能流程

**添加出差**
```
點擊 + → AddTripView → 輸入信息 → 保存 → 顯示在列表
```

**添加費用**
```
進入出差 → 點擊添加費用 → 輸入金額和分類 → 拍照 → 保存
```

**查看統計**
```
切換到統計標籤 → 自動生成圓餅圖 → 顯示費用占比和總額
```

**多設備同步**
```
本地修改 → SwiftData 保存 → CloudKit 自動同步 → 其他設備自動更新
```

## 🏗️ 架構設計

使用 **MVVM 架構**：
- **Models**：數據結構（Trip、Expense）
- **ViewModels**：業務邏輯（計算、驗證）
- **Views**：UI 視圖（展示數據）
- **Services**：數據操作（CRUD、同步）

好處：
- 職責清晰
- 易於測試
- 易於維護

## 📸 主要畫面

1. **行程列表** - 展示所有出差，顯示天數和總費用
2. **行程詳情** - 顯示該出差的所有費用
3. **添加費用** - 表單輸入費用信息和拍照
4. **統計圖表** - 圓餅圖展示費用分類占比
5. **設置** - 應用設置

## 🔄 核心功能實現

**CRUD 操作**
- 創建：點擊 + 按鈕，填寫信息保存
- 讀取：列表自動加載所有數據
- 更新：點擊編輯修改信息
- 刪除：滑動或點擊刪除，級聯刪除相關費用

**費用分類**
- 用戶選擇分類（交通/住宿/餐飲/雜支）
- 不同分類顯示不同顏色圖標

**統計計算**
- 所有費用按分類分組
- 計算每個分類的金額和占比
- SwiftCharts 繪製圓餅圖

**雲端同步**
- SwiftData 本地保存
- CloudKit 自動上傳到 iCloud
- 其他設備自動同步

## ⚠️ 已知限制

- 無 OCR 自動分類（未來可能添加）
- 無 PDF 匯出（可能的加分項）
- 無數字簽名功能

## 👨‍💻 開發者

**名字**: 陳憶柔  
**課程**: iOS 應用開發  
**完成日期**: 2025 年 12 月

## 📚 參考資源

- [Apple SwiftUI 官方教程](https://developer.apple.com/tutorials/swiftui)
- [SwiftData 文檔](https://developer.apple.com/documentation/swiftdata)
- [CloudKit 文檔](https://developer.apple.com/icloud/cloudkit/)

---

**版本**: 1.0.0  
**許可證**: MIT