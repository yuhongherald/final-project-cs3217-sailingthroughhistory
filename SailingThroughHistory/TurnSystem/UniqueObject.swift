//
//  UniqueObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

/**
 * A class with an internal identifier queue that manages unique identifiers
 * asynchronously.
 */
class UniqueObject: Unique, Hashable {
    var identifier: Int {
        return _identifier
    }

    static func == (lhs: UniqueObject, rhs: UniqueObject) -> Bool {
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

    init() {
        self._identifier = UniqueObject.getIdentifier()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    deinit {
        let identifier = self.identifier
        UniqueObject.queue.async(flags: .barrier) {
            UniqueObject.identifiers.remove(identifier)
        }
    }
}
