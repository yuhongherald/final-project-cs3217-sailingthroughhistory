//
//  Taken from Jason's PS4
//
//  UIView+Translate.swift
//  GameEngine
//
//  Created by Jason Chong on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//
import UIKit

extension UIView {
    /// Transforms the frame of this view to match the given frame, which is of a different scale due to being in the
    /// given other bound. This view will be scaled and transformed to have a frame equivalent of the given frame.
    ///
    /// - Parameters:
    ///   - otherBounds: The bounds that contain the other frame.
    ///   - otherFrame: The frame to match.
    func translateFromDifferentScale(otherBounds: Rect, otherFrame: Rect) {
        guard let bounds = superview?.bounds else {
            return
        }

        let otherBoundsCg = CGRect(fromRect: otherBounds)
        let otherFrameCg = CGRect(fromRect: otherFrame)
        let ratio = min(bounds.width / otherBoundsCg.width, bounds.height / otherBoundsCg.height)

        /// Transforms the size of the view to match.
        transform =  transform.concatenating(
            CGAffineTransform(scaleX: 1 / frame.width, y: 1 / frame.height))
        transform = transform.concatenating(
            CGAffineTransform(scaleX: ratio * otherFrameCg.width, y: ratio * otherFrameCg.height))

        /// Changes the position of the view to match.
        transform = transform.concatenating(
            CGAffineTransform(translationX: -frame.origin.x, y: -frame.origin.y))
        transform = transform.concatenating(
            CGAffineTransform(translationX: ratio * otherFrameCg.origin.x, y: ratio * otherFrameCg.origin.y))
    }
}
