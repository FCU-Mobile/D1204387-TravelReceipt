    //
    //  EditExpenseView.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/14.
    //

import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var expense: Expense
    
        // MARK: - Form State
    @State private var amount: String = ""
    @State private var currency: String = "TWD"
    @State private var date: Date = Date()
    @State private var category: ExpenseCategory = .miscellaneous
    @State private var storeName: String = ""
    @State private var notes: String = ""
    
        // ✅ 收據圖片
    @State private var receiptImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPhotoSource = false
    @State private var showingReceiptPreview = false
    @State private var imageWasRemoved = false
    
        // 常用貨幣
    private let currencies = ["TWD", "CNY", "JPY", "USD", "EUR", "HKD", "KRW"]
    
        // 驗證
    private var isValid: Bool {
        guard let value = Double(amount), value > 0 else {
            return false
        }
        return true
    }
    
        // 檢查日期是否在行程範圍內
    private var isDateOutOfRange: Bool {
        guard let trip = expense.trip else { return false }
        let calendar = Calendar.current
        let expenseDay = calendar.startOfDay(for: date)
        let tripStart = calendar.startOfDay(for: trip.startDate)
        let tripEnd = calendar.startOfDay(for: trip.endDate)
        return expenseDay < tripStart || expenseDay > tripEnd
    }
    
        // 當前顯示的圖片 Data
    private var currentImageData: Data? {
        if let image = receiptImage {
            return image.jpegData(compressionQuality: 0.7)
        }
        if !imageWasRemoved {
            return expense.receiptImage
        }
        return nil
    }
    
        // 是否有圖片可顯示
    private var hasImage: Bool {
        receiptImage != nil || (!imageWasRemoved && expense.receiptImage != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                    // MARK: - 收據照片
                Section {
                    HStack {
                            // 縮圖預覽（可點擊放大）
                        if let image = receiptImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    showingReceiptPreview = true
                                }
                        } else if !imageWasRemoved, let data = expense.receiptImage, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    showingReceiptPreview = true
                                }
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(width: 80, height: 80)
                                .overlay {
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera")
                                            .font(.title2)
                                        Text("新增")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.gray)
                                }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 12) {
                            Button(action: { showingPhotoSource = true }) {
                                Label("拍照/選擇", systemImage: "photo.badge.plus")
                            }
                            
                            if hasImage {
                                Button(role: .destructive, action: removeImage) {
                                    Label("移除照片", systemImage: "trash")
                                }
                                .foregroundStyle(.red)
                            }
                        }
                    }
                } header: {
                    Text("收據照片")
                } footer: {
                    if hasImage {
                        Text("點擊照片可放大檢視")
                    } else {
                        Text("選填，可拍照或從相簿選取收據")
                    }
                }
                
                    // MARK: - 金額
                Section("金額") {
                    HStack {
                        TextField("輸入金額", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                        
                        Picker("貨幣", selection: $currency) {
                            ForEach(currencies, id: \.self) { curr in
                                Text(curr).tag(curr)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                }
                
                    // MARK: - 分類
                Section("分類") {
                    Picker("選擇分類", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            Text("\(cat.icon) \(cat.displayName)")
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                    // MARK: - 詳細資訊
                Section {
                    DatePicker("日期", selection: $date, displayedComponents: .date)
                    
                    if isDateOutOfRange {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                            Text("費用日期不在行程期間內")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    TextField("商家名稱", text: $storeName)
                    
                    TextField("備註（選填）", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("詳細資訊")
                } footer: {
                    if let trip = expense.trip {
                        Text("行程期間：\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) — \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
            }
            .navigationTitle("編輯費用")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                loadExpenseData()
            }
                // 選擇照片來源
            .confirmationDialog("選擇照片來源", isPresented: $showingPhotoSource) {
                Button("拍照") {
                    showingCamera = true
                }
                Button("從相簿選擇") {
                    showingImagePicker = true
                }
                Button("取消", role: .cancel) { }
            }
                // 相機
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPicker(image: $receiptImage)
                    .ignoresSafeArea()
            }
                // 相簿
            .sheet(isPresented: $showingImagePicker) {
                PhotoPicker(image: $receiptImage)
            }
                // 全螢幕預覽
            .fullScreenCover(isPresented: $showingReceiptPreview) {
                if let data = currentImageData {
                    ReceiptImageView(imageData: data)
                }
            }
                // 新選擇圖片時，重置移除標記
            .onChange(of: receiptImage) { oldValue, newValue in
                if newValue != nil {
                    imageWasRemoved = false
                }
            }
        }
    }
    
        // MARK: - Load Data
    private func loadExpenseData() {
        amount = String(format: "%.0f", expense.amount)
        currency = expense.currency ?? "TWD"
        date = expense.date
        category = expense.category
        storeName = expense.storeName ?? ""
        notes = expense.notes ?? ""
    }
    
        // MARK: - Remove Image
    private func removeImage() {
        receiptImage = nil
        imageWasRemoved = true
    }
    
        // MARK: - Save Changes
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        expense.amount = amountValue
        expense.currency = currency
        expense.date = date
        expense.category = category
        expense.storeName = storeName.isEmpty ? nil : storeName
        expense.notes = notes.isEmpty ? nil : notes
        
            // ✅ 儲存圖片
        if let image = receiptImage {
            expense.receiptImage = image.jpegData(compressionQuality: 0.7)
        } else if imageWasRemoved {
            expense.receiptImage = nil
        }
        
        dismiss()
    }
}

    // MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Trip.self, Expense.self, configurations: config)
    
    let expense = Expense(
        amount: 1500,
        currency: "TWD",
        date: Date(),
        storeName: "測試商家",
        category: .food
    )
    container.mainContext.insert(expense)
    
    return EditExpenseView(expense: expense)
        .modelContainer(container)
}
