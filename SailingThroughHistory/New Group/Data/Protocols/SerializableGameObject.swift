//
//  SerializableGameObject.swift
//  SailingThroughHistory
//
//  Created by Herald on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol SerializableGameObject: Operatable, OpEvaluatable, Printable, Observable, Unique {
    var fields: [String] { get }
    func getField(field: String) -> Any?
    func setField(field: String, object: Any?) -> Bool
}
