//
//  GameAsyncWrap.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class GameAsyncWrap: AsyncWrap {
    private let group: DispatchGroup = DispatchGroup()
    func async(action: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.group.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
                self.group.enter()
                action()
                self.group.leave()
            }
        }
    }
}
