//
//  GameObject.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 16/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class GameObject {
    var images: [String]
    var frame: CGRect
    var loopDuration: TimeInterval = 0
    var startingFrame = 0
    var image: String {
        return images.first ?? ""
    }
    var isAnimated: Bool {
        return images.count > 1 && loopDuration > 0
    }

    init(image: String, frame: CGRect) {
        self.images = [image]
        self.frame = frame
    }

    init(images: [String], frame: CGRect, loopDuration: TimeInterval, startingFrame: Int) {
        self.images = images
        self.frame = frame
        self.loopDuration = loopDuration
        self.startingFrame = startingFrame
    }
}

extension GameObject: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
