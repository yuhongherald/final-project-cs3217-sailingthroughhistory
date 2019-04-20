//
//  Rect.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 24/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// ADT to represent the frame of a object.
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

    /// Constructor for rect with the given parameters.
    ///
    /// - Parameters:
    ///   - originX: The x-coordinate of the top left corner of this Rect.
    ///   - originY: The y-coordinate of the top left corner of this Rect.
    ///   - height: The height of this rect
    ///   - width: The width of this rect
    init(originX: Double, originY: Double, height: Double, width: Double) {
        self.originX = originX
        self.originY = originY
        self.height = height
        self.width = width
    }

    /// Creates a new rect representing the resultant rect when this rect is moved to the input coordinates
    ///
    /// - Parameters:
    ///   - originX: The new x-coordinate of the top left corner.
    ///   - originY: The new y-coordinate of the top left corner.
    /// - Returns: The new rect representing the resultant rect when this rect is moved to the input coordinates
    func movedTo(originX: Double, originY: Double) -> Rect {
        return Rect(originX: originX, originY: originY, height: height, width: width)
    }
}
