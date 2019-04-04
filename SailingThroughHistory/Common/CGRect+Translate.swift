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
    static func translatingFrom(otherBounds: Rect, otherFrame: Rect, to bounds: CGRect) -> CGRect {
        let otherBoundsCg = CGRect(fromRect: otherBounds)
        let otherFrameCg = CGRect(fromRect: otherFrame)
        let ratio = min(bounds.width / otherBoundsCg.width, bounds.height / otherBoundsCg.height)

        /// Transforms the size of the rect to match.
        var newRect =  otherFrameCg.applying(
            CGAffineTransform(scaleX: 1 / otherFrameCg.width, y: 1 / otherFrameCg.height))
        newRect = newRect.applying(
            CGAffineTransform(scaleX: ratio * otherFrameCg.width, y: ratio * otherFrameCg.height))

        /// Changes the position of the rect to match.
        newRect = newRect.applying(
            CGAffineTransform(translationX: -newRect.origin.x, y: -newRect.origin.y))
        newRect = newRect.applying(
            CGAffineTransform(translationX: ratio * otherFrameCg.origin.x, y: ratio * otherFrameCg.origin.y))

        return newRect
    }
}
