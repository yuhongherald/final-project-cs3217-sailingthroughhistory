//
//  UIImageView+ContextDrawable.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 25/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension UIImageView {
    convenience init(fromDrawable drawable: ContextDrawable, withFrame frame: CGRect) {
        self.init(frame: frame)
        self.image = UIImage(named: drawable.image)
        if drawable.isAnimated {
            self.animationImages = drawable.images
                .rotatedLeft(
                    by: UInt(drawable.startingFrame))
                .compactMap { UIImage(named: $0 )}
            self.animationDuration = drawable.loopDuration
            self.startAnimating()
        }
    }
}
