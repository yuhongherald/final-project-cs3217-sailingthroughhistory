//
//  AsyncWrap.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol AsyncWrap {
    func async(action: @escaping () -> Void)
    // include 1 for UI async if needed
}
