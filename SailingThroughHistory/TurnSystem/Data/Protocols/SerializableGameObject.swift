//
//  SerializableGameObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * Conforming to the protocol allows for UI constructed events. (Not done)
 */
protocol SerializableGameObject: ComparableOp, Operatable, Printable, Unique {
    var fields: [String] { get }
    func getField(field: String) -> Any?
    func setField(field: String, object: Any?) -> Bool
}
