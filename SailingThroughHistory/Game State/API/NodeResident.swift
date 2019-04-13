//
//  EntityAtNode.swift
//  SailingThroughHistory
//
//  Created by henry on 13/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation

class NodeResident: Codable {
    let nodeId: Int
    var uiRepresentation: GameObject?

    init(nodeId: Int) {
        self.nodeId = nodeId
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nodeId = try values.decode(Int.self, forKey: .nodeId)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodeId, forKey: .nodeId)
    }

    private enum CodingKeys: String, CodingKey {
        case nodeId
    }

}
