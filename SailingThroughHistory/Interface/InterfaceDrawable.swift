//
//  InterfaceDrawable.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 24/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct InterfaceDrawable {
    let uniqueId: Int
    let images: [String]
    let frame: Rect
    let loopDuration: Double
    let startingFrame: Int
    let interfaceLayer: InterfaceLayer
    var image: String {
        return images.first ?? ""
    }
    var isAnimated: Bool {
        return images.count > 1 && loopDuration > 0
    }

    init(withId uniqueId: Int, image: String, frame: Rect, interfaceLayer: InterfaceLayer) {
        self.uniqueId = uniqueId
        self.images = [image]
        self.frame = frame
        self.interfaceLayer = interfaceLayer
        self.startingFrame = 0
        self.loopDuration = 0
    }

    init(withId uniqueId: Int, images: [String], frame: Rect, interfaceLayer: InterfaceLayer, loopDuration: Double,
         startingFrame: Int) {
        self.uniqueId = uniqueId
        self.images = images
        self.frame = frame
        self.loopDuration = loopDuration
        self.startingFrame = startingFrame
        self.interfaceLayer = interfaceLayer
    }
}

extension InterfaceDrawable: Hashable {
    static func == (lhs: InterfaceDrawable, rhs: InterfaceDrawable) -> Bool {
        return lhs.uniqueId == rhs.uniqueId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }
}
