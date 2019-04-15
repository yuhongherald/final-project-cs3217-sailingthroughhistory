//
//  GameTime+Equatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 8/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

extension GameTime: Equatable {
    static func == (lhs: GameTime, rhs: GameTime) -> Bool {
        return lhs.week == rhs.week &&
               lhs.month == rhs.month &&
               lhs.year == rhs.year
    }
}

extension GameTime: ComparableOp {
    var operators: [GenericComparator] {
        return [EqualOperator<GameTime>(),
                NotEqualOperator<GameTime>()]
    }
}
