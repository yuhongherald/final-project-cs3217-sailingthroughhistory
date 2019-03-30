//
//  GameObject.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 16/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

class GameObject: ReadOnlyGameObject, BaseGameObject {
    var events = [Int: Observer]()

    var objects = [String: Any]()

    var fields: [String] = Field.allCases.map { $0.rawValue }

    var operators = [GenericOperator]()

    var displayName: String {
        didSet {
            objects[Field.displayName.rawValue] = displayName
        }
    }

    var identifier: Int {
        didSet {
            objects[Field.identifier.rawValue] = identifier
        }
    }

    var images: [String]
    let frame: GameVariable<Rect>
    var image: String {
        return images.first ?? ""
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.images = []
        self.frame = GameVariable(value: try container.decode(Rect.self, forKey: .frame))
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.identifier = try container.decode(Int.self, forKey: .identifier)
        self.initializeFields()
    }

    init() {
        self.identifier = 1
        self.images = []
        self.frame = GameVariable(value: Rect())
        self.displayName = ""
        self.initializeFields()
    }

    init(withIdentifier identifier: Int, displayName: String, frame: Rect) {
        self.identifier = identifier
        self.images = []
        self.displayName = displayName
        self.frame = GameVariable(value: frame)
        self.initializeFields()
    }

    init(image: String, frame: Rect) {
        self.frame = GameVariable(value: Rect())
        self.images = []
        self.identifier = 1
        self.displayName = ""
        self.initializeFields()
    }

    func setField(field: String, object: Any?) -> Bool {
        guard let objectField = Field.init(rawValue: field) else {
            return false
        }

        switch objectField {
        case .frame:
            guard let frame = object as? Rect else {
                return false
            }
            self.frame.value = frame
        case .displayName:
            guard let displayName = object as? String else {
                return false
            }
            self.displayName = displayName
        case .identifier:
            guard let identifier = object as? Int else {
                return false
            }
            self.identifier = identifier
        }

        for observer in events.values {
            observer.notify(eventUpdate: EventUpdate(oldValue: objects[field], newValue: object))
        }
        objects[field] = object

        return true
    }

    private func initializeFields() {
        self.objects[Field.frame.rawValue] = self.frame
        self.objects[Field.displayName.rawValue] = self.displayName
        self.objects[Field.identifier.rawValue] = self.identifier
    }

    func subscibeToFrame(with callback: @escaping (Rect) -> Void) {
        frame.subscribe(with: callback)
    }

    func set(frame: Rect) {
        self.frame.value = frame
        self.objects[Field.frame.rawValue] = frame
    }

    private enum CodingKeys: String, CodingKey {
        case frame
        case displayName
        case identifier
    }

    func getField(field: String) -> Any? {
        return objects[field]
    }

    private enum Field: String, CaseIterable {
        case frame
        case displayName
        case identifier
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
        try container.encode(displayName, forKey: .displayName)
        try container.encode(identifier, forKey: .identifier)
    }
}
