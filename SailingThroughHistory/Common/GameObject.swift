//
//  GameObject.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 16/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameObject: Codable, ReadOnlyGameObject {
    var images: [String]
    var frame: Rect
    var loopDuration: Double = 0
    var startingFrame: UInt = 0
    var image: String {
        return images.first ?? ""
    }
    var displayName: String {
        return ""
    }
    var isAnimated: Bool {
        return images.count > 1 && loopDuration > 0
    }

    init() {
        self.images = []
        self.frame = Rect()
    }

    init(image: String, frame: Rect) {
        self.images = [image]
        self.frame = frame
    }

    init(images: [String], frame: Rect, loopDuration: Double, startingFrame: UInt) {
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
