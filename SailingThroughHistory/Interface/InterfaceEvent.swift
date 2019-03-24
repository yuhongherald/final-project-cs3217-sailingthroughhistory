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
    /// TODO :Remove these.
    case move(_: GameObject, toFrame: CGRect)
    case addObject(_: GameObject, atFrame: CGRect)
    case addPath(_: Path)
    case removeObject(_: GameObject)
    case removePath(_: Path)
    case changeMonth(toMonth: String)
    case playerTurnStart(player: GenericPlayer, timeLimit: TimeInterval?, timeOutCallback: () -> Void)
    case playerTurnEnd
    case pauseAndShowAlert(titled: String, withMsg: String)
    case pauseGame
    case resumeGame
    case showTravelChoices(choices: [Node], selectCallback: (GameObject) -> Void)
    case moveDrawable(withId: Int, toFrame: Rect)
    case addDrawable(_: InterfaceDrawable)
    case addInterfacePath(_: InterfacePath)
    case removeDrawable(_: InterfaceDrawable)
    case removeInterfacePath(_: InterfacePath)
}
