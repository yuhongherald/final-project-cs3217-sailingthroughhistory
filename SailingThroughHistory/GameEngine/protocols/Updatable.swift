//
//  Updatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Updatable: Drawable {
    // returns whether there is a notable change in values
    var identifier: Int { get }
    func update() -> Bool
    func checkForEvent() -> GenericGameEvent?
}
