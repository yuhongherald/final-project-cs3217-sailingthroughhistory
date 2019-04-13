//
//  PresetEvent.swift
//  SailingThroughHistory
//
//  Created by Herald on 11/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class PresetEvent: TurnSystemEvent, Activatable {
    private var activeVariable: GameVariable<Bool> = GameVariable<Bool>(value: false)
    var active: Bool {
        get {
            return activeVariable.value
        }
        set {
            activeVariable.value = newValue
            for trigger in triggers where trigger is FlipFlopTrigger {
                guard let trigger = trigger as? FlipFlopTrigger else {
                    continue
                }
                trigger.triggered = newValue
            }
        }
    }

    override init(triggers: [Trigger], conditions: [Evaluate], actions: [Modify], parsable: @escaping () -> String, displayName: String) {
        var newConditions: [Evaluate] = conditions
        newConditions.append(EventCondition<Bool>(first: VariableEvaluatable<Bool>(activeVariable),
                                                  second: Evaluatable<Bool>(true),
                                                  change: EqualOperator<Bool>()))
        super.init(triggers: triggers, conditions: conditions, actions: actions, parsable: parsable, displayName: displayName)
    }
}
