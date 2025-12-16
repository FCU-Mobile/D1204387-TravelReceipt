    //
    //  ExpenseCategory.swift
    //  TravelReceipt
    //
    //  Created by YiJou on 2025/11/13.
    //

import Foundation
import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable {
    case transport
    case lodging
    case food
    case telecom
    case miscellaneous
    
    var displayName: String {
        switch self {
        case .transport: return "交通"
        case .lodging: return "住宿"
        case .food: return "餐飲"
        case .telecom: return "通信"
        case .miscellaneous: return "雜支"
        }
    }
    
    var icon: String {
        switch self {
        case .transport: return "✈️"
        case .lodging: return "🏨"
        case .food: return "🍽️"
        case .telecom: return "📱"
        case .miscellaneous: return "📦"
        }
    }
    
    var color: Color {
        switch self {
        case .transport, .lodging: return .blue
        case .food, .telecom: return .orange
        case .miscellaneous: return .gray
        }
    }
}

