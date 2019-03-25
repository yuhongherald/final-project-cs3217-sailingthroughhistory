//
//  GameObjectProtocol.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 26/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol ReadOnlyGameObject: class {
    var images: [String] { get }
    var frame: Rect { get }
    var loopDuration: Double { get }
    var startingFrame: UInt { get }
    var image: String { get }
    var isAnimated: Bool { get }
}
