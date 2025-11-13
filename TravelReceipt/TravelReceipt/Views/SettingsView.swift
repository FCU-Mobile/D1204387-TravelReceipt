    //
    //  SettingsView.swift
    //  TravelReceipt
    //
    //  Created by YiJou  on 2025/11/14.
    //

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("應用程式") {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("開發者")
                    Spacer()
                    Text("YiJou")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("支援") {
                HStack {
                    Text("回報問題")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("設定")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
