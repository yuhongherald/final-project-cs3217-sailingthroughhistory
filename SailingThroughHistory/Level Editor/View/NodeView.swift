//
//  NodeView.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class NodeView: UIImageView {
    var node: Node
    var nodeLabel: UILabel

    init(node: Node) {
        self.node = node
        self.nodeLabel = NodeView.getBlankLabel()
        super.init(frame: node.frame)
        self.image = UIImage(named: node.image)
        self.node = node
        self.frame = node.frame

        nodeLabel.text = node.name
        nodeLabel.frame.size = CGSize(width: node.frame.size.width, height: 15)
        self.addSubview(nodeLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTo(_ view: UIView, map: Map, with gestures: [UIGestureRecognizer]) {
        map.addNode(node)

        self.isUserInteractionEnabled = true

        for gesture in gestures {
            self.addGestureRecognizer(gesture)
        }
        view.addSubview(self)
    }

    func highlighted(_ highlighted: Bool) {
        if highlighted {
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 3.0
        } else {
            self.layer.borderColor = nil
            self.layer.borderWidth = 0
        }
    }

    private static func getBlankLabel() -> UILabel {
        let label = UILabel()
        label.frame.origin = CGPoint(x: 0, y: -15)
        label.backgroundColor = .white

        label.textAlignment = .center
        label.font = label.font.withSize(10)

        return label
    }
}
