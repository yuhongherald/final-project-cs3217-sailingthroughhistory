//
//  ObjectFrames.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 26/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct ObjectFrames {
    private var objects: [ReadOnlyGameObject]
    private var objectFrames: [ObjectIdentifier: Rect]

    init() {
        self.objects = []
        self.objectFrames = [ObjectIdentifier: Rect]()
    }

    mutating func add(object: ReadOnlyGameObject, currentFrame: Rect) -> Bool {
        assert(checkRep())
        if objectFrames[ObjectIdentifier(object)] != nil {
            assert(checkRep())
            return false
        }

        objects.append(object)
        objectFrames[ObjectIdentifier(object)] = currentFrame
        assert(checkRep())
        return true
    }

    mutating func remove(object: ReadOnlyGameObject) -> Bool {
        assert(checkRep())
        if objectFrames.removeValue(forKey: ObjectIdentifier(object)) == nil {
            assert(checkRep())
            return false
        }

        objects.removeAll { object === $0 }
        assert(checkRep())
        return true
    }

    mutating func move(object: ReadOnlyGameObject, to frame: Rect) -> Bool {
        assert(checkRep())
        if !objects.contains(where: { object === $0 } ) {
            assert(checkRep())
            return false
        }

        objectFrames[ObjectIdentifier(object)] = frame
        assert(checkRep())
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

    func getFrame(for object: ReadOnlyGameObject) -> Rect? {
        return objectFrames[ObjectIdentifier(object)]
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
