//
//  TimeUpdatable.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol TimeUpdatable {
    fileprivate func addToCache(updatables: [Updatable])
    func hasCachedUpdates() -> Bool
    func processCachedUpdates() -> GenericGameEvent?
    func invalidateCache()
}
