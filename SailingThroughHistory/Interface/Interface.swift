//
//  Interface.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Interface {
    let bounds: Rect
    let background: String = "worldmap1815.png"
    let events = GenericPublishSubject<InterfaceEvents>()
    let monthSymbols = Calendar.current.monthSymbols
    let players: [GenericPlayer]
    private(set) var pendingEvents = [InterfaceEvent]()
    private(set) var objectFrames = ObjectFrames()
    private(set) var paths = ObjectPaths()
    private(set) var currentTurnOwner: GenericPlayer?
    private(set) var contextDrawables = [Int: (context: ContextDrawable, frame: Rect)]()

    init(players: [Player], bounds: Rect) {
        self.players = players
        self.bounds = bounds
    }

    /// Add a pending operation to add the given object to the interface. Once commited/broadcasted, rhe frame of the
    /// object in the interface will be its frame at the time this add function is called.
    ///
    /// - Parameter object: The `ReadOnlyGameObject` to add.
    func add(object: ReadOnlyGameObject) {
        pendingEvents.append(.addObject(object, atFrame: object.frame.value))
    }

    /// Add a pending operation to add the given object to the interface. Once commited/broadcasted, the path will be
    /// drawn from and to the two `ReadOnlyGameObject`'s current frame (on broadcast).
    ///
    /// - Parameter path: The `Path` to be drawn.
    func add(path: Path) {
        pendingEvents.append(.addPath(path))
    }

    /// Add a pending operation to remove the `ReadOnlyGameObject`
    ///
    /// - Parameter object: The `ReadOnlyGameObject` to remove.
    func remove(object: ReadOnlyGameObject) {
        pendingEvents.append(.removeObject(object))
    }

    /// Add a pending operation to remove a `Path`.
    ///
    /// - Parameter path: The `Path` to remove.
    func remove(path: Path) {
        pendingEvents.append(.removePath(path))
    }

    /// Add a pending operation to add the given context to the interface.
    ///
    /// - Parameter drawable: The `ContextDrawable` to add.
    func add(context: ContextDrawable, toFrame frame: Rect) {
        pendingEvents.append(.addContext(context, frame: frame))
    }

    /// Add a pending operation to remove the `ReadOnlyGameObject`
    ///
    /// - Parameter drawable: The `InterfaceDrawable` to remove.
    func removeContext(withId uniqueId: Int) {
        pendingEvents.append(.removeContext(withId: uniqueId))
    }

    /// Add a pending operation to update the position of the drawable with the given id to the given frame on the
    /// interface. Nothing happens if no drawable in the interface matches the id.
    ///
    /// - Parameters:
    ///   - drawableId: The unique id of the drawable to move
    ///   - frame: The new frame of the drawable
    func updatePositionOfDrawable(withId drawableId: Int, to frame: Rect) {
        pendingEvents.append(.moveContext(withId: drawableId, toFrame: frame))
    }

    /// Add a pending operation to update the position of given object to the interface. Once commited/broadcasted,
    /// the frame of the object in the interface will be its frame at the time this updatePosition function is called.
    ///
    /// - Parameter object: The `ReadOnlyGameObject` to add.
    func updatePosition(of object: ReadOnlyGameObject) {
        pendingEvents.append(.move(object, toFrame: object.frame.value))
    }

    /// Add a pending operation to update the month displayed on the interface. Months are indexed from 0-11 (inclusive)
    ///
    /// - Parameter newMonth: The index of the new month.
    func changeMonth(to newMonth: Int) {
        if !monthSymbols.indices.contains(newMonth) {
            preconditionFailure("\(newMonth) is not a valid month.")
        }
        pendingEvents.append(.changeMonth(toMonth: monthSymbols[newMonth]))
    }

    /// Add a pending operation to pause and show an alert with the given title and msg. Event batches
    /// commited/broadcasted after this operation will not be executed until this alert is dismissed by the user.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - msg: The description of the alert.
    func pauseAndShowAlert(titled title: String, withMsg msg: String) {
        pendingEvents.append(.pauseAndShowAlert(titled: title, withMsg: msg))
    }

    /// Add a pending operation to start the input player's turn on the interface. A countdown timer will be shown if
    /// timeLimit is not nil. This timer starts from the time the user dismisses the alert notifying them of this event.
    ///
    /// - Parameters:
    ///   - player: The `Player` "owner" of the turn.
    ///   - timeLimit: The time limit (in seconds).
    ///   - timeOutCallback: Called when the time limit is reached.
    func playerTurnStart(player: GenericPlayer, timeLimit: Double?, timeOutCallback: @escaping () -> Void) {
        pendingEvents.append(.playerTurnStart(player: player, timeLimit: timeLimit, timeOutCallback: timeOutCallback))
    }

    /// Add a pending operation to highlight the given nodes and allow the user to tap on them. Once tapped,
    /// selectCallback will be called with the tapped node being the parameter.
    ///
    /// - Parameters:
    ///   - nodes: The nodes to be available for selection.
    ///   - selectCallback: Function to be called when a node is selected.
    func showTravelChoices(_ nodes: [Node], selectCallback: @escaping (ReadOnlyGameObject) -> Void) {
        pendingEvents.append(.showTravelChoices(choices: nodes, selectCallback: selectCallback))
    }

    /// TODO: Change method name to commit and broadcast
    /// Commits all pending operations and broadcasts all pending operations to any observers. All pending operations
    /// will be animated simultaneously with the same duration and pending operations from future calls of this function
    /// will be blocked until the animations have been completed.
    ///
    /// - Parameter duration: The duration of the animations for the pending operations.
    func broadcastInterfaceChanges(withDuration duration: Double) {
        var validEvents = [InterfaceEvent]()
        for event in pendingEvents {
            if !commit(event: event) {
                continue
            }

            validEvents.append(event)
        }

        let toBroadcast = InterfaceEvents(events: validEvents, duration: duration)
        pendingEvents = []
        events.on(next: toBroadcast)
    }

    private func commit(event: InterfaceEvent) -> Bool {
        switch event {
        case .addPath(let path):
            if !addPathToState(path: path) {
                return false
            }
        case .addObject(let object, let frame):
            if !objectFrames.add(object: object, currentFrame: frame) {
                return false
            }
        case .move(let object, let frame):
            if !objectFrames.move(object: object, to: frame) {
                return false
            }
        case .removePath(let path):
            paths.remove(path: path)
        case .removeObject(let object):
            if !objectFrames.remove(object: object) {
                return false
            }
            paths.removeAllPathsAssociated(with: object)
        case .addContext(let drawable, let frame):
            if contextDrawables[drawable.uniqueId] == nil {
                return false
            }
            contextDrawables[drawable.uniqueId] = (context: drawable, frame: frame)
        case .moveContext(let contextId, let frame):
            guard let contextInfo = contextDrawables[contextId] else {
                return false
            }
            contextDrawables[contextId] = (context: contextInfo.context, frame: frame)
        case .removeContext(let contextId):
            if contextDrawables.removeValue(forKey: contextId) == nil {
                return false
            }
        case .playerTurnStart(let player, _, _):
            currentTurnOwner = player
        case .playerTurnEnd:
            currentTurnOwner = nil
        default:
            break
        }

        return true
    }

    /// Subscribes to this Interface. The callback will be called when `InterfaceEvents` are broadcasted.
    ///
    /// - Parameter callback: Called when `InterfaceEvents` are broadcasted as the parameter.
    func subscribe(callback: @escaping (InterfaceEvents) -> Void) {
        return events.subscribe(with: callback)
    }

    /// Add a pending operation to end the player turn
    func endPlayerTurn() {
        pendingEvents.append(.playerTurnEnd)
    }

    private func addPathToState(path: Path) -> Bool {
        // TODO
        /*
        if !objectFrames.contains(object: path.fromObject) ||
            !objectFrames.contains(object: path.toObject) {
            return false
        }
        */

        paths.add(path: path)

        return true
    }
}
