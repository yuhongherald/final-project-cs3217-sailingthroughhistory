//
//  NodeView.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/**
 * UIImageView for Node, used for convenience to get UI representation of a node.
 */
class NodeView: UIImageView {
    var node: Node
    var nodeLabel: UILabel
    var icon: UIImageView?

    init(node: Node) {
        self.node = node
        self.nodeLabel = NodeView.getBlankLabel()
        super.init(frame: CGRect(fromRect: node.frame))

        nodeLabel.text = node.name
        nodeLabel.frame.size = CGSize(width: node.frame.width, height: 15)
        nodeLabel.adjustsFontSizeToFitWidth = true
        if let image = Resources.Icon.of(node) {
            self.image = UIImage(named: image)
        }

        node.objects.forEach { object in
            if let image = Resources.Icon.of(object) {
                self.image = UIImage(named: image)
            }
        }

        self.addSubview(nodeLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Update image of a node view after new object is added into it.
    func update() {
        node.objects.forEach { object in
            if let image = Resources.Icon.of(object) {
                self.image = UIImage(named: image)
            }
        }
    }

    /// Add NodeView to provided superView: view and add Node model to Map model
    /// - Parameters:
    ///   - view: superView where NodeView is added
    ///   - map: Map model where Node is added
    ///   - gestures: gesture recognizers added to NodeView
    func addTo(_ view: UIView, map: Map, with gestures: [UIGestureRecognizer]) {
        map.addNode(node)

        self.isUserInteractionEnabled = true

        for gesture in gestures {
            self.addGestureRecognizer(gesture)
        }
        view.addSubview(self)
    }

    /// Remove NodeView from superView and remove Node model from Map model
    /// - Parameters:
    ///   - map: Map model where Node is removed from
    func removeFrom(map: Map) {
        map.removeNode(node)
        self.removeFromSuperview()
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
