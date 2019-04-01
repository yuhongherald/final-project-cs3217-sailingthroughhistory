//
//  PathView.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/1/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class PathView: CAShapeLayer {
    var fromNodeView: Node?
    var toNodeView: Node?

    static func == (lhs: PathView, rhs: PathView) -> Bool {
        return lhs.fromNodeView == rhs.fromNodeView && lhs.toNodeView === rhs.toNodeView
    }

    override init() {
        super.init()
        self.strokeColor = UIColor.black.cgColor
        self.lineWidth = 2.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(from fromNode: Node, to toNode: Node) {
        self.fromNodeView = fromNode
        self.toNodeView = toNode
    }
}
