//
//  EdgeADT.swift
//  SailingThroughHistory
//
//  Created by Herald on 31/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EdgeData: UniqueObject, BaseGameObject {
    var operators: [GenericOperator] = []
    var evaluators: [GenericEvaluateOperator] = []
    
    var displayName: String
    var events: [Int : Observer] = [Int: Observer]()
    var objects: [String : Any?] = [String: Any?]()
    var fields: [String] = [
        "From",
        "To"
    ]
    
    init(displayName: String, from: NodeData, to: NodeData) {
        self.displayName = displayName
        super.init()
        _ = setField(field: fields[0], object: from)
        _ = setField(field: fields[1], object: to)
    }
    
    func setField(field: String, object: Any?) -> Bool {
        switch field {
        case fields[0]:
            guard let _ = object as? NodeData else {
                return false
            }
        case fields[1]:
            guard let _ = object as? NodeData else {
                return false
            }
        default:
            return false
        }
        objects[field] = object
        return true
    }
    
}
