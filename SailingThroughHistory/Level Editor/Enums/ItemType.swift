//
//  File.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

enum ItemType: String, Codable, CaseIterable {
    case teaLeaves = "Tea Leaves"
    case silk = "Silk"
    case perfume = "Perfume"
    case opium = "Opium"
    case food = "Food"

    func getUnitWeight() -> Int {
        switch self {
        case .teaLeaves:
            return 25
        case .silk:
            return 20
        case .perfume:
            return 10
        case .opium:
            return 10
        case .food:
            return 5
        }
    }
}
