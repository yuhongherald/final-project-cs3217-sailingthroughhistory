//
//  EventTableControllerDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Delegate for EventsTableController. Notified when the user wishes to toggle an event.
protocol EventTableControllerDelegate: class {
    func toggle(event: PresetEvent, enabled: Bool)
}
