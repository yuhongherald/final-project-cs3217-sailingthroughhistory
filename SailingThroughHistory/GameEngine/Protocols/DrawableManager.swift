//
//  DrawableManager.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol DrawableManager {
    var addedObjects: Set<GameObject> { get }
    var updatedObjects: Set<GameObject> { get }
    var removedObjects: Set<GameObject> { get }
    func approveChanges()
}
