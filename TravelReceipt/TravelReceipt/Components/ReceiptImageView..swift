//
//  ReceiptImageView..swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/16.
//

import SwiftUI

struct ReceiptImageView: View {
    let imageData: Data
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = lastScale * value
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                        // 限制縮放範圍
                                    if scale < 1.0 {
                                        withAnimation {
                                            scale = 1.0
                                            lastScale = 1.0
                                        }
                                    } else if scale > 4.0 {
                                        withAnimation {
                                            scale = 4.0
                                            lastScale = 4.0
                                        }
                                    }
                                }
                        )
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    withAnimation {
                                        if scale > 1.0 {
                                            scale = 1.0
                                            lastScale = 1.0
                                        } else {
                                            scale = 2.0
                                            lastScale = 2.0
                                        }
                                    }
                                }
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .background(Color.black)
            .navigationTitle("收據照片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

    // MARK: - 收據縮圖元件
struct ReceiptThumbnail: View {
    let imageData: Data?
    var size: CGFloat = 60
    
    var body: some View {
        if let data = imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: "receipt")
                        .foregroundStyle(.gray)
                }
        }
    }
}
