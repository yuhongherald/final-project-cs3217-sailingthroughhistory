//
//  Updatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Updatable {
    // returns whether there is a notable change in values
    func update(time: Double) -> Bool
    func checkForEvent() -> GenericGameEvent?
}
