//
//  Board.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericGameLogic: TimeUpdatable, DrawableManager {
    func updateForTime(deltaTime: Double) -> GenericGameEvent?
}
