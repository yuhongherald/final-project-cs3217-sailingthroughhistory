//
//  FlipFlopTrigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// A trigger that only fires once
class FlipFlopTrigger: Trigger {
    private var triggered: Bool = true
    func hasTriggered() -> Bool {
        return triggered
    }
    
    func resetTrigger() {
        triggered = false
    }
}
