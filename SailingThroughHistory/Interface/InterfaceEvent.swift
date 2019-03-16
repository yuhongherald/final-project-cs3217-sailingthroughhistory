//
//  InterfaceEvent.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

enum InterfaceEvent {
    case toggleUpgradesMenu(isVisible: Bool)
    case arriveAt(port: Port)
    case move(_: GameObject, toFrame: CGRect)
    case add(_: GameObject, atFrame: CGRect)
    case changeMonth(toMonth: String)
}
