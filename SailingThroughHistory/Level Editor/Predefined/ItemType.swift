//
//  File.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

enum ItemType: String {
    case teaLeaves
    case silk
    case perfume
    case opium

    static func getAll() -> [ItemType] {
        return [.teaLeaves, .silk, .perfume, .opium]
    }
}
