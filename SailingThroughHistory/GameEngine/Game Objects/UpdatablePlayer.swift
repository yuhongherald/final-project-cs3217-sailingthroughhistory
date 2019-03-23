//
//  UpdatablePlayer.swift
//  SailingThroughHistory
//
//  Created by Herald on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UpdatablePlayer: GameObject, Updatable {
    var status: UpdatableStatus = .add
    private let location: GameVariable<Location>

    init(location: GameVariable<Location>) {
        self.location = location
        super.init(image: Resources.Ships.british[0], frame: CGRect())
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    func update(weeks: Double) -> Bool {
        // TODO: Get movement speed of player, do multi-node movement
        // TODO: Check if endNode is dock
        location.value = Location(start: location.value.start,
                                  end: location.value.end,
                                  fractionToEnd: location.value.fractionToEnd
                                    + weeks * Double(GameConstants.weeksInMonth),
                                  isDocked: location.value.isDocked)
        return true // always moving
    }

    func checkForEvent() -> GenericGameEvent? {
        // no pirate event currently
        return nil
    }

}
