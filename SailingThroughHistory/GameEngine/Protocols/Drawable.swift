//
//  Drawable.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Drawable {
    var identifier: Int { get }
    var position: Vector2F { get }
    var scale: Vector2F { get }
    var rotation: Float { get }
    var data: VisualAudioData? { get }
}
