//
//  ObjectFrames.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 26/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct ObjectFrames {
    var objects: [ReadOnlyGameObject]
    var objectFrames: [ObjectIdentifier: Rect]

    init() {
        self.objects = []
        self.objectFrames = [ObjectIdentifier: Rect]()
    }

    mutating func add(object: ReadOnlyGameObject, currentFrame: Rect) -> Bool {
        if objectFrames[ObjectIdentifier(object)] != nil {
            return false
        }

        objects.append(object)
        objectFrames[ObjectIdentifier(object)] = currentFrame
        return true
    }

    mutating func remove(object: ReadOnlyGameObject) -> Bool {
        if objectFrames.removeValue(forKey: ObjectIdentifier(object)) == nil {
            return false
        }

        objects.removeAll { object === $0 }
        return true
    }

    mutating func move(object: ReadOnlyGameObject, to frame: Rect) -> Bool {
        if !objects.contains(where: { object === $0 } ) {
            return false
        }

        objectFrames[ObjectIdentifier(object)] = frame
        return true
    }

    func getAllObjectFrames() -> [(object: ReadOnlyGameObject, frame: Rect)] {
        var allFrames = [(ReadOnlyGameObject, Rect)]()
        for object in objects {
            guard let frame = objectFrames[ObjectIdentifier(object)] else {
                fatalError("Object frame could not be found.")
            }

            allFrames.append((object, frame))
        }

        return allFrames
    }

    func contains(object: ReadOnlyGameObject) -> Bool {
        return objectFrames[ObjectIdentifier(object)] != nil
    }

    private func checkRep() -> Bool {
        if objects.count != objectFrames.count {
            return false
        }

        for object in objects {
            if objectFrames[ObjectIdentifier(object)] == nil {
                return false
            }
        }

        return true
    }
}
