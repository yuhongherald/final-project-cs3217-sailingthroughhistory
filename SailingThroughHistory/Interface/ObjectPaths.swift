//
//  ObjectPaths.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct ObjectPaths {
    var paths = [GameObject: [Path]]()
    var allPaths: Set<Path> {
        return Set(paths.values
            .flatMap { $0 })
    }

    init() {
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        for path in allPaths {
            if !paths[path.fromObject, default: []].contains(path) ||
                !paths[path.toObject, default: []].contains(path) {
                return false
            }
        }

        return true
    }

    mutating func add(path: Path) {
        assert(checkRep())
        paths[path.fromObject, default: []].append(path)
        paths[path.toObject, default: []].append(path)
        assert(checkRep())
    }

    mutating func remove(path: Path) {
        assert(checkRep())
        paths[path.toObject]?.removeAll { $0 == path }
        paths[path.fromObject]?.removeAll { $0 == path }
        assert(checkRep())
    }

    mutating func removeAllPathsAssociated(with object: GameObject) {
        assert(checkRep())
        paths[object]?.forEach { path in
            paths[path.toObject]?.removeAll { otherPath in path == otherPath }
        }

        paths[object] = nil
        assert(checkRep())
    }

    func contains(path: Path) {
        return allPaths.contains(path)
    }

    func getPathsFor(object: GameObject) -> [Path] {
        return paths[object, default: []]
    }
}
