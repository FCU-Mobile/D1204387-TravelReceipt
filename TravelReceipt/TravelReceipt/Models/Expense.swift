//
//  Expense.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/11/13.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var currency: String
    var notes: String? = nil
    var date: Date
    var trip: Trip? = nil
    var category: ExpenseCategory? = nil
    
    init(amount: Double, currency: String = "TWD", date: Date, notes: String? = nil, trip: Trip? = nil, category: ExpenseCategory? = nil) {
        self.amount = amount
        self.currency = currency
        self.date = date
        self.notes = notes
        self.trip = trip
        self.category = category
    }
}
