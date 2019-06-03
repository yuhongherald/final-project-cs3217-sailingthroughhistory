//
//  Evaluatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 3/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/**
 * The base class for Evaluatables. Evaluates a primitive value.
 */
class Evaluatable<T> {
    private var _value: T
    var value: T {
        get {
            return _value
        }
        set {
            _value = newValue
        }
    }
    init(_ value: T) {
        self._value = value
    }
}
