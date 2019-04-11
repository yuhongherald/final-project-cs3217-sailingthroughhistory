//
//  CountdownLabelView.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import CountdownLabel

@objc protocol CountdownLabelView: class {
    func set(isHidden: Bool)
    func setCountDownTime(seconds: TimeInterval)
    func start()
}

extension CountdownLabel: CountdownLabelView {
    @objc func set(isHidden: Bool) {
        self.isHidden = isHidden
    }

    @objc func start() {
        self.animationType = .Burn
        self.start(completion: nil)
    }

    @objc func setCountDownTime(seconds: TimeInterval) {
        /// This is due to a bug in the library where the label is minutes
        /// but the input is taken as seconds
        self.setCountDownTime(minutes: seconds)
    }
}
