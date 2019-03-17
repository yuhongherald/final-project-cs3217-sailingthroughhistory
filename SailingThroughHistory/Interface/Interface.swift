//
//  Interface.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import RxSwift
import UIKit

class Interface {
    let bounds: CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 2048, height: 1536))
    let background: String = "1799-Asia.png"
    let events = PublishSubject<InterfaceEvents>()
    let monthSymbols = Calendar.current.monthSymbols
    var pendingEvents = [InterfaceEvent]()
    var objects = [GameObject]()
    var paths = [GameObject: [Path]]()

    func add(object: GameObject) {
        objects.append(object)
        pendingEvents.append(.addObject(object, atFrame: object.frame))
    }

    func updatePosition(of object: GameObject) {
        pendingEvents.append(.move(object, toFrame: object.frame))
    }

    func changeMonth(to newMonth: Int) {
        if !monthSymbols.indices.contains(newMonth) {
            preconditionFailure("\(newMonth) is not a valid month.")
        }
        pendingEvents.append(.changeMonth(toMonth: monthSymbols[newMonth]))
    }

    func pauseAndShowAlert(titled title: String, withMsg msg: String) {
        pendingEvents.append(.pauseAndShowAlert(titled: title, withMsg: msg))
    }

    func add(path: Path) {
        if paths[path.fromObject] == nil {
            paths[path.fromObject] = []
        }

        if paths[path.toObject] == nil {
            paths[path.toObject] = []
        }

        paths[path.fromObject]?.append(path)
        paths[path.toObject]?.append(path)
        pendingEvents.append(.addPath(path))
    }

    /// TODO: Modify to take in current player.
    func playerTurnStart() {
        pendingEvents.append(.playerTurnStart)
    }

    func broadcastInterfaceChanges(withDuration duration: TimeInterval) {
        let toBroadcast = InterfaceEvents(events: pendingEvents, duration: duration)
        pendingEvents = []
        events.on(.next(toBroadcast))
    }
}
