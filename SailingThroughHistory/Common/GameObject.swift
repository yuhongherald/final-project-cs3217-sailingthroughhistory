//
//  GameObject.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 16/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//


class GameObject: ReadOnlyGameObject {
    var images: [String]
    let frame: GameVariable<Rect>
    var image: String {
        return images.first ?? ""
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.images = []
        self.frame = GameVariable(value: try container.decode(Rect.self, forKey: .frame))
    }

    init() {
        self.images = []
        self.frame = GameVariable(value: Rect())
    }

    init(image: String, frame: Rect) {
        self.frame = GameVariable(value: Rect())
        self.images = []
    }

    func subscibeToFrame(with callback: @escaping (Rect) -> Void) {
        frame.subscribe(with: callback)
    }

    func set(frame: Rect) {
        self.frame.value = frame
    }

    func addToMap(map: Map) {
        map.addGameObject(gameObject: self)
    }

    private enum CodingKeys: String, CodingKey {
        case frame
    }
}

extension GameObject: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: GameObject, rhs: GameObject) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension GameObject: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frame.value, forKey: .frame)
    }
}
