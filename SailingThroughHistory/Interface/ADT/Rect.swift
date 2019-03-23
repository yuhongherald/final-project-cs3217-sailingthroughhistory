//
//  Rect.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 24/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct Rect {
    let originX: Float
    let originY: Float
    let height: Float
    let width: Float

    init?(originX: Float, originY: Float, height: Float, width: Float) {
        if originX < 0 || originY < 0 || height < 0 || width < 0 {
            return nil
        }

        self.originX = originX
        self.originY = originY
        self.height = height
        self.width = width

        assert(checkRep())
    }

    private func checkRep() -> Bool {
        return originX >= 0 && originY >= 0 && height >= 0 && width >= 0
    }
}
