//
//  GameAsyncWrap.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameAsyncWrap: AsyncWrap {
    private var startTime: Double = 0
    private let group: DispatchGroup = DispatchGroup()
    func async(action: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.group.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
                self.group.enter()
                action()
                self.group.leave()
            }
        }
    }

    func getTimestamp() -> Double {
        return getCurrentTime() - startTime
    }

    private func getCurrentTime() -> Double {
        return Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
    }

    func resetTimer() {
        startTime = getCurrentTime()
    }
}
