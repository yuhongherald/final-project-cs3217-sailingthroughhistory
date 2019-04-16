//
//  UIBezierPath+Arrow.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension UIBezierPath {
    func drawArrow(from start: CGPoint, to end: CGPoint,
                   arrowAngle: CGFloat = CGFloat.pi / 6, headLength: CGFloat = 30) {
        self.move(to: start)
        self.addLine(to: end)
        let startEndAngle = atan((end.y - start.y) / (end.x - start.x))
            + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)
        let arrowLine1 = CGPoint(x: end.x + headLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle),
                                 y: end.y - headLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: end.x + headLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle),
                                 y: end.y - headLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))

        self.addLine(to: arrowLine1)
        self.move(to: end)
        self.addLine(to: arrowLine2)
    }
}
