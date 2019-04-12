//
//  EditableObject.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/18/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

enum EditMode {
    case sea
    case path
    case port
    case pirate
    case weather
    case item
    case erase
    case startingNode
    case portOwnership

    func getNodeView(name: String, at center: CGPoint) -> NodeView? {
        switch self {
        case .sea:
            return NodeView(node: Sea(name: name, originX: Double(center.x),
                                      originY: Double(center.y)))
        case .port:
            return NodeView(node: Port(team: nil, name: name, originX: Double(center.x),
                                       originY: Double(center.y)))
        default:
            return nil
        }
    }
}
