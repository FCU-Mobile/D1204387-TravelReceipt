//
//  TripListView.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/14.
//

import SwiftUI
import SwiftData

struct TripListView: View {
    @Query private var trips: [Trip]
    
    var body: some View {
        List(trips) { trip in
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.name)
                    .font(.headline)
                Text(trip.destination)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                    Text("-")
                    Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

#Preview {
    TripListView()
}
