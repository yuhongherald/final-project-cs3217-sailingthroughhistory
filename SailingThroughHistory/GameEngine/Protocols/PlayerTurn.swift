//
//  PlayerTurn.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// MARKED AS OBSOLETE: COUNTDOWN GIVES A CALLBACK TO RETURN TO REGULAR EXECUTION
protocol PlayerTurn {
    var playerIdentifier: String { get set }
    var timeLeft: Double { get set }
}
