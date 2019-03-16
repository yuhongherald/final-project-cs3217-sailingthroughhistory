//
//  Sea.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Sea: GameObject {
    private static let seaNodeSize = CGSize(width: 50, height: 50)
    private static let seaNodeImage = "sea-node.png"

    init(pos: CGPoint) {
        super.init(image: Sea.seaNodeImage, frame: CGRect(origin: pos, size: Sea.seaNodeSize))
    }
}
