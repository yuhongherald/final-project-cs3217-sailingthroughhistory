//
//  InventoryData.swift
//  SailingThroughHistory
//
//  Created by Herald on 31/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class InventoryData: UniqueObject, BaseGameObject {
    var operators: [GenericOperator] = []
    var evaluators: [GenericEvaluateOperator] = []
    
    var displayName: String
    var events: [Int : Observer] = [Int: Observer]()
    var objects: [String : Any?] = [String: Any?]()
    var fields: [String] = [
        "Capacity",
        "Opium"
        // add other item support here
        // TODO: Current items have no weight. Introduce weights using item table
    ]
    
    init(displayName: String, capacity: Int) {
        self.displayName = displayName
        super.init()
        _ = setField(field: fields[0], object: capacity)
    }

    func setField(field: String, object: Any?) -> Bool {
        switch field {
        case fields[0]:
            guard let _ = object as? Int else {
                return false
            }
        case fields[1]:
            guard let _ = object as? Int else {
                return false
            }
        default:
            return false
        }
        objects[field] = object
        return true
    }

}
