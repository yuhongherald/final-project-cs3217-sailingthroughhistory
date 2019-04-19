//
//  PathView.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/1/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class PathView: CAShapeLayer {
    var shipPath: Path?

    static func == (lhs: PathView, rhs: PathView) -> Bool {
        return lhs.shipPath == rhs.shipPath
    }

    override init() {
        super.init()
        self.strokeColor = UIColor.black.cgColor
        self.lineWidth = 2.0
    }

    init(path: Path) {
        super.init()
        self.strokeColor = UIColor.black.cgColor
        self.lineWidth = 2.0
        self.shipPath = path
        let bazier = UIBezierPath()
        bazier.move(to: CGPoint(x: path.fromNode.frame.midX,
                                y: path.fromNode.frame.midY))
        bazier.addLine(to: CGPoint(x: path.toNode.frame.midX,
                                   y: path.toNode.frame.midY))
        self.path = bazier.cgPath
        path.modifiers.forEach { self.add($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(path: Path) {
        self.shipPath = path
    }

    func add(_ modifier: Volatile) {
        guard let path = shipPath else {
            return
        }
        self.shipPath?.modifiers.append(modifier)

        let layer = CALayer()
        let image = UIImage(named: Resources.Icon.weather)?.cgImage
        layer.contentsGravity = .resizeAspect
        layer.contents = image
        let midX = (path.fromNode.frame.midX + path.toNode.frame.midX) / 2
        let midY = (path.fromNode.frame.midY + path.toNode.frame.midY) / 2
        layer.frame = CGRect(x: midX, y: midY, width: 50, height: 50)
        self.addSublayer(layer)
    }
}
