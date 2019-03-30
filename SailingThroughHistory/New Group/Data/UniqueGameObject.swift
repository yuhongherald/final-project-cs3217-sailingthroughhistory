//
//  UniqueGameObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// base class for all game objects in TurnSystem. Marked as abstract
protocol UniqueGameObject: Hashable, SerializableGameObject {
}
