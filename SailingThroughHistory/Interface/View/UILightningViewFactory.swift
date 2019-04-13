//
//  UILightningViewFactory.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 12/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import URWeatherView

enum UILightningViewFactory {
    static func getLightningView(frame: CGRect) -> UILightningView {
        return URWeatherView(frame: frame)
    }
}
