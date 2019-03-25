//
//  ContextViewLayer.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct ContextViewController {
    let view: UIView
    let contextViews = [Int: UIImageView]()
    let interfaceBounds: CGRect

    init(view: UIView, interfaceBounds: CGRect) {
        self.view = view
        self.interfaceBounds = interfaceBounds
    }

    func add(context: ContextDrawable, withFrame frame: Rect, withDuration duration: TimeInterval,
             completion callback: @escaping () -> Void) {
        contextViews[context.uniqueId]?.removeFromSuperview()
        let viewFrame = CGRect.translatingFrom(otherBounds: interfaceBounds, otherFrame: CGRect(fromRect: frame), to: view.bounds)
        let contextView = UIImageView(fromDrawable: context, withFrame: viewFrame)
        contextView.alpha = 0
        view.addSubview(contextView)

        UIView.animate(withDuration: duration, animations: {
            contextView.alpha = 1
        }, completion: { _ in
            callback()
        })
    }

    func moveContext(withId contextId: Int, toFrame frame: Rect, withDuration duration: TimeInterval,
                     completion callback: @escaping () -> Void) {
        guard let contextView = contextViews[contextId] else {
            callback()
            return
        }

        let viewFrame = CGRect.translatingFrom(otherBounds: interfaceBounds, otherFrame: CGRect(fromRect: frame), to: view.bounds)

        UIView.animate(withDuration: duration, animations: {
            contextView.frame = viewFrame
        }, completion: { _ in
            callback()
        })
    }

    func removeContext(withId contextId: Int, withDuration duration: TimeInterval,
                       completion callback: @escaping () -> Void) {
        guard let contextView = contextViews[contextId] else {
            callback()
            return
        }

        contextView.fadeOutAndRemove(withDuration: duration, completion: callback)
    }
}
