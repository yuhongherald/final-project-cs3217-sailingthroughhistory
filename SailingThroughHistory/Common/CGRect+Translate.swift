//
//  CGRect+Translate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 16/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension CGRect {
    /// Calculates the CGRect for a given bounds that's equivalent to the input CGRect contained in another bound.
    ///
    /// - Parameters:
    ///   - otherBounds: The bounds that contain the other frame.
    ///   - otherFrame: The frame to match.
    ///   - bounds: The current bounds.
    static func translatingFrom(otherBounds: CGRect, otherFrame: CGRect, to bounds: CGRect) -> CGRect {
        let ratio = min(bounds.width / otherBounds.width, bounds.height / otherBounds.height)

        /// Transforms the size of the rect to match.
        var newRect =  otherFrame.applying(
            CGAffineTransform(scaleX: 1 / otherFrame.width, y: 1 / otherFrame.height))
        newRect = newRect.applying(
            CGAffineTransform(scaleX: ratio * otherFrame.width, y: ratio * otherFrame.height))

        /// Changes the position of the rect to match.
        newRect = newRect.applying(
            CGAffineTransform(translationX: -newRect.origin.x, y: -newRect.origin.y))
        newRect = newRect.applying(
            CGAffineTransform(translationX: ratio * otherFrame.origin.x, y: ratio * otherFrame.origin.y))

        return newRect
    }
}
