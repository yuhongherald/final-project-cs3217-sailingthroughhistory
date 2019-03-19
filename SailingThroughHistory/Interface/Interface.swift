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
    let events = InterfacePublishSubject<InterfaceEvents>()
    let disposeBag = DisposeBag()
    let monthSymbols = Calendar.current.monthSymbols
    let players: [Player]
    var pendingEvents = [InterfaceEvent]()
    var objectFrames = [GameObject: CGRect]()
    var paths = [GameObject: [Path]]()
    var currentTurnOwner: Player?

    init(players: [Player]) {
        self.players = players
    }

    func add(object: GameObject) {
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
        pendingEvents.append(.addPath(path))
    }

    func playerTurnStart(player: Player, timeLimit: TimeInterval?, timeOutCallback: @escaping () -> Void) {
        pendingEvents.append(.playerTurnStart(player: player, timeLimit: timeLimit, timeOutCallback: timeOutCallback))
    }

    func showTravelChoices(_ nodes: [Node], selectCallback: @escaping (GameObject) -> Void) {
        pendingEvents.append(.showTravelChoices(choices: nodes, selectCallback: selectCallback))
    }

    /// TODO: Change method name to commit and broadcast
    func broadcastInterfaceChanges(withDuration duration: TimeInterval) {
        let toBroadcast = InterfaceEvents(events: pendingEvents, duration: duration)
        for event in pendingEvents {
            switch event {
            case .addPath(let path):
                addPathToState(path: path)
            case .addObject(let object, let frame):
                objectFrames[object] = frame
            case .removePath(let path):
                paths[path.toObject]?.removeAll { $0 == path }
                paths[path.fromObject]?.removeAll { $0 == path }
            case .removeObject(let object):
                objectFrames[object] = nil
                paths[object]?.forEach { path in
                    paths[path.toObject]?.removeAll { otherPath in path == otherPath }
                }
            case .playerTurnStart(let player, _, _):
                currentTurnOwner = player
            case .playerTurnEnd:
                currentTurnOwner = nil
            default:
                break
            }
        }
        pendingEvents = []
        events.on(next: toBroadcast)
    }

    func remove(object: GameObject) {
        pendingEvents.append(.removeObject(object))
    }

    func remove(path: Path) {
        pendingEvents.append(.removePath(path))
    }

    func subscribe(callback: @escaping (Event<InterfaceEvents>) -> Void) {
        return events.subscribe(callback: callback)
    }

    private func addPathToState(path: Path) {
        if paths[path.fromObject] == nil {
            paths[path.fromObject] = []
        }

        if paths[path.toObject] == nil {
            paths[path.toObject] = []
        }

        paths[path.fromObject]?.append(path)
        paths[path.toObject]?.append(path)
    }
}
