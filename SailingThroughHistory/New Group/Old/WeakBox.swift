//
//  Weakbox.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

final class WeakBox<A: AnyObject> {
    weak var unbox: A?
    init(_ value: A?) {
        unbox = value
    }
}
