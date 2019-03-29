//
//  Observer.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Observer: Unique {
    func notify(eventUpdate: EventUpdate?)
}
