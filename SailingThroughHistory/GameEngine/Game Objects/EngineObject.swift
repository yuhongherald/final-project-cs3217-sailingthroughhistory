//
//  EngineObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

// alternative to GameObject. Currently not used
class EngineObject: Hashable {
    enum Status {
        case moving
        case grid
        case ghost
        case destroying
        case destroyed
    }
    
    static func == (lhs: EngineObject, rhs: EngineObject) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    private static func getIdentifier() -> Int {
        var identifier: Int = 0 // dummy value
        queue.sync {
            while identifiers.contains(nextID) {
                nextID += 1 // naive implementation
            }
            identifiers.insert(nextID)
            identifier = nextID
            nextID += 1
        }
        return identifier
    }
    
    private static var nextID: Int = 0
    private static var identifiers = Set<Int>()
    private static let queue = DispatchQueue(label: "EngineObjectQueue", attributes: .concurrent)
    let identifier: Int
    
    var position: Vector2F = Vector2F.zero
    // rotation is from 0 tp 2pi radians
    var rotation: Float = 0
    // scale not supported currently
    var scale: Vector2F = Vector2F.one
    var velocity: Vector2F = Vector2F.zero
    var status: Status = Status.moving
    
    init() {
        self.identifier = EngineObject.getIdentifier()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    deinit {
        let identifier = self.identifier
        EngineObject.queue.async(flags: .barrier) {
            EngineObject.identifiers.remove(identifier)
        }
    }
}
