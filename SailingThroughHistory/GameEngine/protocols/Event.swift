//
//  Event.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GameEvent {
    // TODO: Create a formatted message based on window API
    var timestamp: Double { get set }
    var message: String { get set }
    var eventType: EventType { get set }
    // image?
    // sound
}
