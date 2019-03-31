//
//  MapData.swift
//  SailingThroughHistory
//
//  Created by Herald on 30/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class MapData: UniqueObject, BaseGameObject {
    var operators: [GenericOperator] = []
    var evaluators: [GenericEvaluateOperator] = []
    
    var displayName: String
    var events: [Int : Observer] = [Int: Observer]()
    var objects: [String : Any?] = [String: Any?]()
    var fields: [String] = [
        "Nodes",
        "Edges"
        // TODO: Getting from an array seems to be a big problem, performance hit.
        // Enumerate ints
    ]
    
    init(displayName: String) {
        self.displayName = displayName
        super.init()
        _ = setField(field: fields[0], object: [NodeData]())
        _ = setField(field: fields[1], object: [EdgeData]())
    }

}
