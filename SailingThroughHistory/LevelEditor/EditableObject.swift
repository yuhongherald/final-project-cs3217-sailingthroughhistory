//
//  EditableObject.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/18/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

enum EditableObject {
    case sea
    case path
    case port
    case pirate
    case erase

    func getObject(at center: CGPoint) -> Node? {
        switch self {
        case .sea:
            return Sea(name: "", pos: center)
        case .port:
            return Port(name: "", pos: center)
        case .pirate:
            return Pirate(name: "", pos: center)
        default:
            return nil
        }
    }
}
