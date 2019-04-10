//
//  MonthWithinCondition.swift
//  SailingThroughHistory
//
//  Created by Herald on 9/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class MonthWithinCondition: Evaluate {
    private let gameTime: GameVariable<GameTime>
    private let start: Int
    private let end: Int

    init(gameTime: GameVariable<GameTime>, start: Int, end: Int) {
        self.gameTime = gameTime
        self.start = start
        self.end = end
    }

    func evaluate() -> Bool {
        return gameTime.value.month >= start && gameTime.value.month <= end ||
        start > end && (gameTime.value.month >= start || gameTime.value.month <= end)
    }
}
