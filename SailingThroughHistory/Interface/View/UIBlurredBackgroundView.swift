//
//  UIBlurredBackgroundView.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UIBlurredBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        blurBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        blurBackground()
    }

    private func blurBackground() {
        self.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.frame = self.bounds
        blurView.alpha = 0.7
        self.insertSubview(blurView, at: 0)
    }
}
