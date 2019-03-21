//
//  Updatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameObjectBox {
    fileprivate var gameObject: GameObject
    init(gameObject: GameObject) {
        self.gameObject = gameObject
    }
}

protocol Updatable: Drawable {
    // returns whether there is a notable change in values
    var gameObjectBox: GameObjectBox { get }
    func update() -> Bool
    func checkForEvent() -> GenericGameEvent?
}

class UpdatableWrapper: Hashable {
    let updatable: Updatable
    init(updatable: Updatable) {
        self.updatable = updatable
    }
    func hash(into hasher: inout Hasher) {
        return updatable.gameObjectBox.gameObject.hash(into: &hasher)
    }
    
    static func == (lhs: UpdatableWrapper, rhs: UpdatableWrapper) -> Bool {
        return lhs.updatable.gameObjectBox.gameObject ==
            rhs.updatable.gameObjectBox.gameObject
    }
}
