//
//  Port.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//
import UIKit

class Port: Node {
    private static let portNodeSize = CGSize(width: 50, height: 50)
    private static let portNodeImage = "port-node.png"

    init(name: String, pos: CGPoint) {
        super.init(name: name, image: Port.portNodeImage, frame: CGRect(origin: pos, size: Port.portNodeSize))
    }
}
