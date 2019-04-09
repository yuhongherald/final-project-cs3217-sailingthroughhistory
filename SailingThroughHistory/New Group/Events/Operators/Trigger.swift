//
//  Trigger.swift
//  SailingThroughHistory
//
//  Created by Herald on 8/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Trigger {
    func hasTriggered() -> Bool
    
    func resetTrigger()
}
