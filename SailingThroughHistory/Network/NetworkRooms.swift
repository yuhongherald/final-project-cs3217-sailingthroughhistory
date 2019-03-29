//
//  NetworkRooms.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol NetworkRooms {
    func subscribe(with callback: @escaping ([String]) -> Void)
}
