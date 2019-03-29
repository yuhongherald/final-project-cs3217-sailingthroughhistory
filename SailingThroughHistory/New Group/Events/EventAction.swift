//
//  EventAction.swift
//  SailingThroughHistory
//
//  Created by Herald on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class EventAction: ReadOnlyEventAction {
    var objectIdentifier: SerializableGameObject?
    var objectField: String?
    var evaluatable: GenericEvaluatable?

    func modify() {
        // evaluate the condition
        guard let objectField = objectField, let evaluatable = evaluatable else {            return
        }
        // TODO: Come up with a better type safe idea, maybe in setfield
        let result = evaluatable.evaluate()
        _ = objectIdentifier?.setField(field: objectField, object: result)
    }
}
