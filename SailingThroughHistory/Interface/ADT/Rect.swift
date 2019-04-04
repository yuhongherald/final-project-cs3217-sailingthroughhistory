//
//  Rect.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 24/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct Rect: Codable, Equatable {
    let originX: Double
    let originY: Double
    let height: Double
    let width: Double
    var midX: Double {
        return originX + width / 2
    }
    var midY: Double {
        return originY + width / 2
    }

    init() {
        self.originX = 0
        self.originY = 0
        self.height = 0
        self.width = 0
    }

    init(originX: Double, originY: Double, height: Double, width: Double) {
        self.originX = originX
        self.originY = originY
        self.height = height
        self.width = width
    }

    func movedTo(originX: Double, originY: Double) -> Rect {
        return Rect(originX: originX, originY: originY, height: height, width: width)
    }
}
