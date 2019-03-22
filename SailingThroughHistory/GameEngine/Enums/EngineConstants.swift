//
//  GameConstants.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum EngineConstants {
    static let largestTimeStep: Double = 1
    static let forecastDuration: Double = 1
    static let weeksToSeconds: Double = 1
    static let fastestGameSpeed: Double = 1
    static let slowestGameSpeed: Double = 0.5
    static let smallestEngineTick: Double = 0.01

}

enum GameConstants {
    static let weeksInMonth: Int = 4
    static let monthsInYear: Int = 12
    static let playerTurnDuration: Double = 30
}

enum Resources {
    enum Weather {
        static let monsoon: [String] = ["sea-node.png"]
    }
    enum Ships {
        static let british: [String] = ["ship"]
        static let dutch: [String] = ["ship"]
        static let pirate: [String] = ["pirate-node"]
        static let npc: [String] = ["ship"]
    }
    enum Avatars {
        static let british: String = ""
        static let dutch: String = ""
        static let pirate: String = ""
        static let npc: String = ""
    }
    enum Items {
        static let opium: String = ""
        static let perfume: String = ""
        static let silk: String = ""
        static let teaLeaves: String = ""
    }
    enum Misc {
        static let currency: String = ""
        static let portNode: String = "port-node"
        static let pirateNode: String = "pirate-node"
        // static let edge: String = ""
    }
}
