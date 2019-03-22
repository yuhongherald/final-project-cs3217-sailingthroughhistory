//
//  DrawableManager.swift
//  SailingThroughHistory
//
//  Created by Herald on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol DrawableManager {
    func getAddedDrawables() -> [GameObject]
    func getUpdatedDrawables() -> [GameObject]
    func getDeletedDrawables() -> [GameObject]
    func approvedDeletedDrawables()
}
