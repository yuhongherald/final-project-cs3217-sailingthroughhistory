//
//  NodeData.swift
//  SailingThroughHistory
//
//  Created by Herald on 31/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class NodeData: UniqueObject, BaseGameObject {
    var operators: [GenericOperator] = []
    var evaluators: [GenericEvaluateOperator] = []
    
    var displayName: String
    var events: [Int : Observer] = [Int: Observer]()
    var objects: [String : Any?] = [String: Any?]()
    var fields: [String] = []
    
    init(displayName: String) {
        self.displayName = displayName
        super.init()
    }
    
    func setField(field: String, object: Any?) -> Bool {
        return false
    }
    
}
