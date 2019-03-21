//
//  Stopwatch.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class Stopwatch {
    private var time: Double = 0
    private var timer: Timer?
    private var isPlaying: Bool = false
    private let smallestInterval: Double

    init(smallestInterval: Double) {
        self.smallestInterval = Double.clamp(smallestInterval, 1e-9, smallestInterval)
    }
    func resetTimer() {
        timer?.invalidate()
        time = 0.0
        isPlaying = false
    }
    func start() {
        guard !isPlaying else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: smallestInterval, target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil, repeats: true)
        isPlaying = true
    }
    func stop() {
        timer?.invalidate()
        isPlaying = false
    }
    func getTimestamp() -> Double {
        return time
    }

    @objc
    private func updateTimer() {
        time += smallestInterval
    }
}
