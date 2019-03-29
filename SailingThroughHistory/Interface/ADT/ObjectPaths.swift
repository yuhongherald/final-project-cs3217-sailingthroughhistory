//
//  ObjectPaths.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct ObjectPaths {
    var paths = [ObjectIdentifier: [Path]]()
    var allPaths: Set<Path> {
        return Set(paths.values
            .flatMap { $0 })
    }

    init() {
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        for path in allPaths {
            if !paths[ObjectIdentifier(path.fromNode), default: []].contains(path) ||
                !paths[ObjectIdentifier(path.toNode), default: []].contains(path) {
                return false
            }
        }

        return true
    }

    mutating func add(path: Path) {
        assert(checkRep())
        paths[ObjectIdentifier(path.fromNode), default: []].append(path)
        paths[ObjectIdentifier(path.toNode), default: []].append(path)
        assert(checkRep())
    }

    mutating func remove(path: Path) {
        assert(checkRep())
        paths[ObjectIdentifier(path.toNode)]?.removeAll { $0 == path }
        paths[ObjectIdentifier(path.fromNode)]?.removeAll { $0 == path }
        assert(checkRep())
    }

    mutating func removeAllPathsAssociated(with object: ReadOnlyGameObject) {
        assert(checkRep())
        paths[ObjectIdentifier(object)]?.forEach { path in
            paths[ObjectIdentifier(path.toNode)]?.removeAll { otherPath in path == otherPath }
        }

        paths[ObjectIdentifier(object)] = nil
        assert(checkRep())
    }

    func contains(path: Path) -> Bool {
        return allPaths.contains(path)
    }

    func getPathsFor(object: ReadOnlyGameObject) -> [Path] {
        return paths[ObjectIdentifier(object), default: []]
    }
}
