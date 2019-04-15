//
//  GameTimeWithin.swift
//  SailingThroughHistory
//
//  Created by Herald on 7/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class MonthWithin: GenericComparator {
    private let start: Int
    private let end: Int
    var displayName: String {
        return "between \(start) and \(end) month"
    }
    init(start: Int, end: Int) {
        self.start = max(start, 0) % 12 + 1
        self.end = max(end, 0) % 12 + 1
    }
    func compare(first: Any?, second: Any?) -> Bool {
        guard first is GameTime,
            let secondTime = second as? GameTime else {
            return false
        }
        if start > end &&
            secondTime.month >= start || secondTime.month <= end {
            // wrapped
            return true
        }
        if secondTime.month >= start && secondTime.month <= end {
            return true
        }
        return false
    }
}
