    //
    //  ContentView.swift
    //  TravelReceipt
    //
    //  Created by YiJou  on 2025/11/12.
    //

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @State private var showingAddTrip = false
    
    var body: some View {
        TabView {
            Tab("行程", systemImage: "list.bullet") {
                NavigationStack {
                    Group{
                        if trips.isEmpty {
                            EmptyStateView()
                        } else {
                            TripListView()
                        }
                    }
                    .navigationTitle("旅遊記帳")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingAddTrip = true}){
                                    Image(systemName: "plus")
                                }
                        }
                    }
                }
            }
            
            Tab("統計", systemImage: "chart.pie") {
                NavigationStack {
                    StatisticsView()
                }
            }
            Tab("設定", systemImage: "gear") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .sheet(isPresented: $showingAddTrip) {
            AddTripView()
        }
    }
}
    
struct EmptyStateView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "airplane")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
                
                Text("開始您的第一趟旅程")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("點擊右上角的 + 來新增行程")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
#Preview {
        ContentView()
            .modelContainer(try! ModelContainer(for: Trip.self, Expense.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
}
