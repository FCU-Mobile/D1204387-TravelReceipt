//
//  TripListView.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/14.
//

import SwiftUI
import SwiftData

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    
    var body: some View {
        List {
            ForEach(trips, id: \.id) { trip in
                NavigationLink(destination: TripDetailView(trip: trip)) {
                    TripRowView(trip: trip)
                }
            }
            .onDelete(perform: deleteTrips)
        }
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        let sortedTrips = trips.sorted(by: { $0.startDate > $1.startDate })
        for index in offsets {
            let toDelete = sortedTrips[index]
            modelContext.delete(toDelete)
        }    }
}
    // MARK: - Trip Row View
struct TripRowView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(trip.name.isEmpty ? "未命名行程" : trip.name)
                .font(.headline)
            
            Text(trip.destination ?? "未知目的地")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                Text("—")
                Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        TripListView()
    }
    .modelContainer(for: [Trip.self, Expense.self], inMemory: true)
}
