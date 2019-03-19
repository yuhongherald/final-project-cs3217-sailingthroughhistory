//
//  UpdatableObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Updatable {
    var type: UpdatableType { get }
    func update(gameTime: Double) -> Location?
}
