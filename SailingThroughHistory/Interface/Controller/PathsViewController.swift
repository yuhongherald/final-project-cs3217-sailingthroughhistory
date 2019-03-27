//
//  PathsViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

struct PathsViewController {
    private var paths = ObjectPaths()
    private var pathLayers = [Path: CALayer]()
    private unowned let mainController: MainGameViewController
    private let view: UIView

    init(view: UIView, mainController: MainGameViewController) {
        self.view = view
        self.mainController = mainController
    }

    mutating func add(path: Path, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        if paths.contains(path: path) {
            return
        }

        guard let fromFrame = mainController.getFrame(for: path.fromObject),
            let toFrame = mainController.getFrame(for: path.toObject) else {
                return
        }

        paths.add(path: path)

        addToView(path: path, from: fromFrame, to: toFrame, withDuration: duration, callback: callback)
    }

    private mutating func addToView(path: Path, from fromFrame: CGRect, to toFrame: CGRect, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        let startPoint = CGPoint(x: fromFrame.midX, y: fromFrame.midY)
        let endPoint = CGPoint(x: toFrame.midX, y: toFrame.midY)
        let bezierPath = UIBezierPath()
        let layer = CAShapeLayer()
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: endPoint)
        layer.path = bezierPath.cgPath
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 4.0
        layer.lineDashPattern = [10.0, 2.0]
        view.layer.addSublayer(layer)
        pathLayers[path] = layer
        CATransaction.begin()
        CATransaction.setCompletionBlock(callback)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = duration
        layer.add(animation, forKey: "drawLineAnimation")
        CATransaction.commit()
    }

    mutating func remove(path: Path, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        paths.remove(path: path)
        let layer = pathLayers.removeValue(forKey: path)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            layer?.removeFromSuperlayer()
            callback()
        }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        /* set up animation */
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = duration
        layer?.add(animation, forKey: "drawLineAnimation")
        CATransaction.commit()
    }

    mutating func removeAllPathsAssociated(with object: ReadOnlyGameObject, withDuration duration: TimeInterval) {
        for path in paths.getPathsFor(object: object) {
            remove(path: path, withDuration: duration, callback: {})
        }
    }
}
