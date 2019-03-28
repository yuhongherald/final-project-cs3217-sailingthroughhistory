//
//  NetworkError.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum NetworkError: Error {
    case pushError(message: String)
    case encodeError(message: String)
    case pullError(message: String)
}
