//
//  ObjectPaths.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 22/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// ADT used by ObjectsController to store paths that have been registered.
struct NodePaths {
    private var paths = [Node: [Path]]()
    var allPaths: Set<Path> {
        return Set(paths.values
            .flatMap { $0 })
    }

    init() {
        assert(checkRep())
    }

    private func checkRep() -> Bool {
        for path in allPaths {
            if !paths[path.fromNode, default: []].contains(path) ||
                !paths[path.toNode, default: []].contains(path) {
                return false
            }
        }

        return true
    }

    /// Adds the given path
    ///
    /// - Parameter path: The path to add
    mutating func add(path: Path) {
        assert(checkRep())
        if allPaths.contains(path) {
            return
        }
        paths[path.fromNode, default: []].append(path)
        paths[path.toNode, default: []].append(path)
        assert(checkRep())
    }

    /// Removes the given path
    ///
    /// - Parameter path: The path to remove
    mutating func remove(path: Path) {
        assert(checkRep())
        paths[path.toNode]?.removeAll { $0 == path }
        paths[path.fromNode]?.removeAll { $0 == path }
        assert(checkRep())
    }

    /// Checks if the given path has already been added.
    ///
    /// - Parameter path: The path to check for
    /// - Returns: true if the path already exists in this ADT, false otherwise.
    func contains(path: Path) -> Bool {
        return allPaths.contains(path)
    }
}
