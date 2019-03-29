//
//  EventConditionFactory.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventConditionFactory {
    private let gameObject: SerializableGameObject
    init(gameObject: SerializableGameObject) {
        self.gameObject = gameObject
    }

    func createEventCondition() -> EventCondition {
        return EventCondition()
    }
}
