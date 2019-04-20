//
//  EventPresetsTest.swift
//  SailingThroughHistoryTests
//
//  Created by Herald on 20/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import XCTest
@testable import SailingThroughHistory

class EventPresetsTest: XCTestCase {
    func uniqueIdentifierTest() {
        let presets = TestClasses.createEventPresets()
        var set: [Int: PresetEvent]
        for preset in presets {
            if set.contains(where: { $0.0 == preset.identifier }) {
                XCTFail(message: "Non-unique keys")
            }
            set[preset.identifier] = preset
        }
    }
}
