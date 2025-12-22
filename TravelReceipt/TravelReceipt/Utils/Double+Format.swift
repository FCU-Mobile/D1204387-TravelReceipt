//
//  Double+Format.swift
//  TravelReceipt
//
//  Created by YiJou  on 2025/12/22.
//

import Foundation

extension Double {
    var formattedAmount: String {
        self.formatted(.number
            .grouping(.automatic)
            .precision(.fractionLength(0...2))
        )
    }
}
