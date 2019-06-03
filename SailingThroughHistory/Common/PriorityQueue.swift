// Copyright (c) 2018 NUS CS3217. All rights reserved.

/**
 The `PriorityQueue` accepts and maintains the elements in an order specified by
 their priority. For example, a Minimum Priority Queue of integers will serve
 (poll) the smallest integer first.

 Elements with the same priority are allowed, and such elements may be served in
 any order arbitrarily.

 `PriorityQueue` is a generic type with a type parameter `Type` that has to be
 `Comparable` so that `Type` can be compared.

 - Authors: CS3217
 - Date: 2018
 */
struct PriorityQueue<Type: Comparable> {
    /// Creates either a Min or Max `PriorityQueue`. Defaults to `min = true`.
    /// - Parameter min: Whether to return smallest elements first.
    /// Uses a binary heap implementation, root at index 0
    /// Given element at index i, its left child is 2i + 1 and right 2i + 2
    private let isMin: Bool
    private var backEndArray = [Type]()

    init(min: Bool = true) {
        isMin = min
    }

    /// Adds the element.
    mutating func add(_ item: Type) {
        backEndArray.append(item)
        bubbleUp(index: count - 1)
    }

    /// Returns the currently highest priority element.
    /// - Returns: the element if not nil
    func peek() -> Type? {
        return backEndArray.first
    }

    /// Removes and returns the highest priority element.
    /// - Returns: the element if not nil
    mutating func poll() -> Type? {
        guard let highestPriorityElement = peek() else {
            return nil
        }
        guard let elementToSwap = backEndArray.popLast() else {
            return nil
        }
        if count == 0 {
            return highestPriorityElement
        }
        backEndArray[0] = elementToSwap
        bubbleDown(index: 0)
        return highestPriorityElement
    }

    /// The number of elements in the `PriorityQueue`.
    var count: Int {
        return backEndArray.count
    }

    /// Whether the `PriorityQueue` is empty.
    var isEmpty: Bool {
        return backEndArray.isEmpty
    }

    /// Moves the element down the heap until child elements
    /// are not higher priority than the element
    private mutating func bubbleDown(index: Int) {
        //no children
        if 2 * index + 1 >= count {
            return
        }

        let childIndex: Int
        if 2 * index + 2 < count && isHigherPriority(from: backEndArray[2 * index + 2],
                                                            to: backEndArray[2 * index + 1]) {
            childIndex = 2 * index + 2
        } else {
            childIndex = 2 * index + 1
        }

        if isHigherPriority(from: backEndArray[childIndex], to: backEndArray[index]) {
            backEndArray.swapAt(childIndex, index)
            bubbleDown(index: childIndex)
        }
    }

    /// Moves the element up the heap until parent element
    /// is not lower priority than the element
    private mutating func bubbleUp(index: Int) {
        // No more parent, element is at top of heap
        if index <= 0 {
            return
        }

        let parentIndex = (index - 1) / 2

        if isLowerPriority(from: backEndArray[parentIndex], to: backEndArray[index]) {
            backEndArray.swapAt(parentIndex, index)
            bubbleUp(index: parentIndex)
        }
    }

    /// Returns if original has lower priority than comparedTo.
    private func isLowerPriority(from fromType: Type, to toType: Type) -> Bool {
        return isMin ? fromType > toType : fromType < toType
    }

    /// Returns if original has higher priority than comparedTo.
    private func isHigherPriority(from fromType: Type, to toType: Type) -> Bool {
        return isMin ? fromType < toType : fromType > toType
    }

}
