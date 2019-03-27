//
//  InterfaceDrawable.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 24/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct ContextDrawable {
    let uniqueId: Int
    let images: [String]
    let loopDuration: Double
    let startingFrame: Int
    var image: String {
        return images.first ?? ""
    }
    var isAnimated: Bool {
        return images.count > 1 && loopDuration > 0
    }

    init(withId uniqueId: Int, image: String) {
        self.uniqueId = uniqueId
        self.images = [image]
        self.startingFrame = 0
        self.loopDuration = 0
    }

    init(withId uniqueId: Int, images: [String], loopDuration: Double,
         startingFrame: Int) {
        self.uniqueId = uniqueId
        self.images = images
        self.loopDuration = loopDuration
        self.startingFrame = startingFrame
    }
}

extension ContextDrawable: Hashable {
    static func == (lhs: ContextDrawable, rhs: ContextDrawable) -> Bool {
        return lhs.uniqueId == rhs.uniqueId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }
}
