//
//  PortAdminError.swift
//  SailingThroughHistory
//
//  Created by henry on 14/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Represents the various types of errors when setting a port's tax.
import Foundation

enum PortAdminError: Error {
    case exceedMaxTax(maxTaxAmount: Int)
    case belowMinTax(minTaxAmount: Int)
    case badPortOwnership

    func getMessage() -> String {
        switch self {
        case .exceedMaxTax(maxTaxAmount: let maxTaxAmount):
            return "Maximum tax you can set is \(maxTaxAmount)"
        case .belowMinTax(minTaxAmount: let minTaxAmount):
            return "Minimum tax you can set is \(minTaxAmount)"
        case .badPortOwnership:
            return "Unable to set tax to port not owned by your team!"
        }
    }
}
