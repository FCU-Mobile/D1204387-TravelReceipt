//
//  StatisticsView.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/14.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var trips: [Trip]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("統計視圖")
                .font(.title2)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("總行程數：")
                    Spacer()
                    Text("\(trips.count)")
                        .fontWeight(.semibold)
                }
                
                if !trips.isEmpty {
                    HStack {
                        Text("總支出：")
                        Spacer()
                        Text("計算中...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationTitle("統計")
    }
}

#Preview {
    StatisticsView()
}
