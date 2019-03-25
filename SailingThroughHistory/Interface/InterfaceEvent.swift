//
//  InterfaceEvent.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum InterfaceEvent {
    case addObject(_: ReadOnlyGameObject, atFrame: Rect)
    case move(_: ReadOnlyGameObject, toFrame: Rect)
    case removeObject(_: ReadOnlyGameObject)
    case addPath(_: Path)
    case removePath(_: Path)
    case addContext(_: ContextDrawable, frame: Rect)
    case moveContext(withId: Int, toFrame: Rect)
    case removeContext(withId: Int)
    case changeMonth(toMonth: String)
    case playerTurnStart(player: GenericPlayer, timeLimit: Double?, timeOutCallback: (() -> Void)?)
    case playerTurnEnd
    case pauseAndShowAlert(titled: String, withMsg: String)
    case showTravelChoices(choices: [Node], selectCallback: (ReadOnlyGameObject) -> Void)
    case pauseGame
    case resumeGame
}
