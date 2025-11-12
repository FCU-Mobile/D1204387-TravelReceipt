//
//  Trip.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/13.
//

import Foundation
import SwiftData

@Model
final class Trip {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var totalBudget: Double? = nil
    var notes: String? = nil
    var expenses: [Expense] = []
    
    init(name: String, destination: String, startDate: Date, endDate: Date, totalBudget: Double? = nil, notes: String? = nil) {
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.totalBudget = totalBudget
        self.notes = notes
    }
}
    
    
