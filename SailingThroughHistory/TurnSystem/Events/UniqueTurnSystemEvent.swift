//
//  UniqueTurnSystemEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class UniqueTurnSystemEvent: TurnSystemEvent, Hashable {
    override var identifier: Int {
        get {
            return _identifier
        }
        set {
            // discard
        }
    }
    
    static func == (lhs: UniqueTurnSystemEvent, rhs: UniqueTurnSystemEvent) -> Bool {
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
    private static let queue = DispatchQueue(label: "UniqueTurnSystemEventQueue",
                                             attributes: .concurrent)
    private let _identifier: Int
    
    override init(triggers: [Trigger], conditions: [Evaluate],
                  actions: [Modify?], parsable: @escaping () -> String, displayName: String) {
        self._identifier = UniqueTurnSystemEvent.getIdentifier()
        super.init(triggers: triggers, conditions: conditions,
                   actions: actions, parsable: parsable, displayName: displayName)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    deinit {
        let identifier = self.identifier
        UniqueTurnSystemEvent.queue.async(flags: .barrier) {
            UniqueTurnSystemEvent.identifiers.remove(identifier)
        }
    }
}
