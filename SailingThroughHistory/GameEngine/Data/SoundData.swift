//
//  Sound.swift
//  SailingThroughHistory
//
//  Created by Herald on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// A struct that holds information for playing a sound
// owner is the object that returns it
struct SoundData {
    static let none = SoundData(identifier: -1, resource: "", start: 0, end: 0, speed: 0)
    let identifier: Int
    let resource: String
    let start: Double
    let end: Double
    let speed: Double
    var loop: Bool = false
    var status: SoundStatus = SoundStatus.noChange

    init(identifier: Int,resource: String,
         start: Double, end: Double, speed: Double) {
        self.identifier = identifier
        self.resource = resource
        self.start = start
        self.end = end
        self.speed = speed
    }
    
}
