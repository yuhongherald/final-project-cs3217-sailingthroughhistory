//
//  Identifiable.swift
//  SailingThroughHistory
//
//  Created by Herald on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Identifiable {
    associatedtype Identifier: Equatable
    var identifier: Identifier { get }
}
