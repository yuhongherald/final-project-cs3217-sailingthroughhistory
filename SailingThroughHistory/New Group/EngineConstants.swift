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
    static let playerTurnDuration: Double = 120
    static let numOfTurn: Int = 20
    static let monsoonMultiplier: Double = 2
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

    enum Flag {
        static let british: String = "british-flag.png"
        static let dutch: String = "dutch-flag.png"
    }

    enum Icon {
        static let port: String = "port-node.png"
        static let sea: String = "sea-node.png"
        static let pirate: String = "pirate-node.png"
        static let weather: String = "weather-icon.png"

        static func of(_ object: Any) -> String? {
            if object is Port {
                return Resources.Icon.port
            }

            if object is Sea {
                return Resources.Icon.sea
            }

            if object is PirateUI {
                return Resources.Icon.pirate
            }
            return nil
        }
    }
}

enum Default {
    enum Item {
        static let buyValue: Int = 100
        static let sellValue: Int = 100
    }
    enum Weather {
        static let strengths: [Float] = [0, 0, 0, 0]
    }

    enum Suffix {
        static let background: String = "background"
    }

    enum Background {
        static let image: String = "worldmap1815"
    }
}
