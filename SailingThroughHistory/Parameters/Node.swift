//
//  Node.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Node: GameObject {
    let name: String
    var neighbours = [Node]()

    init(name: String, image: String, frame: Rect) {
        self.name = name
        super.init(image: image, frame: frame)
    }

    required init(from decoder: Decoder) throws {
        // TODO: deal with neighbours?
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        neighbours = try values.decode([Node].self, forKey: .neighbours)

        let superDecoder = try values.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(neighbours, forKey: .neighbours)

        let superencoder = container.superEncoder()
        try super.encode(to: superencoder)
    }

    public func getNodesInRange(range: Double) -> [Node] {
        return []
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case neighbours
    }
}
