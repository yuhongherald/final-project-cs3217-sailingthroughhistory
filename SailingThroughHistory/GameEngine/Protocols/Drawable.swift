//
//  Drawable.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Drawable {
    var status: UpdatableStatus { get set }
    var data: VisualAudioData? { get }
    var gameObject: GameObject { get }// hot fix for API mismatch
}

extension Drawable {
    var data: VisualAudioData? {
        get {
            return nil
        }
    }
}
