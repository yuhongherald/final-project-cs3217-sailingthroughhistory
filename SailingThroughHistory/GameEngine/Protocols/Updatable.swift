//
//  Updatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Updatable {
    var status: UpdatableStatus { get set }
    var identifier: Int { get } // marked for deletion
    var data: VisualAudioData? { get }
    // returns whether there is a notable change in values
    func update() -> Bool
    func checkForEvent() -> GenericGameEvent?
}
