//
//  ObservableGameObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

// gameobjects should all inherit from this
protocol BaseGameObject {
    var fields: [String] { get }
    func getField(field: String) -> Any?
    func setField(field: String, object: Any?) -> Bool
}
