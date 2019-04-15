//
//  UILightningView.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 12/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import URWeatherView

protocol UILightningView { //: UIView
    func initView()
    func stop()
    func start()
}

extension URWeatherView: UILightningView {
    func start() {
        let option = UREffectLightningOption(lineThickness: 100)
        self.isUserInteractionEnabled = false
        let times = [0.1, 0.103, 0.14,
                     0.17, 0.173, 0.20,
                     0.35, 0.353, 0.38,
                     0.385, 0.388, 0.415,
                     0.54, 0.543, 0.57,
                     0.69, 0.693, 0.72,
                     0.74, 0.743, 0.77,
                     0.93, 0.933, 0.96]
        let lightningShowTimes = [times[0] - 0.005, times[4] - 0.005, times[7] - 0.005, times[10] - 0.005,
                                  times[13] - 0.005, times[16] - 0.005, times[19] - 0.005, times[22] - 0.005]
        self.startWeatherScene(.lightning, duration: 6.0, showTimes: lightningShowTimes,
                               userInfo: [URWeatherKeyLightningOption: option])
    }

    func initView() {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        guard let blank = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        UIGraphicsEndImageContext()
        self.initView(mainWeatherImage: blank, backgroundImage: blank)
    }
}
