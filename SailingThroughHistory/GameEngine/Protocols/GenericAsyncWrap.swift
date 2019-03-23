//
//  AsyncWrap.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol GenericAsyncWrap {
    func async(action: @escaping () -> Void)
}
