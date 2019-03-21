//
//  Array.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

extension Array {
    func rotatedLeft(by distance: UInt) -> Array {
        return self.indices
            .map { self[($0 + Int(distance)) % self.count] }
    }
}
