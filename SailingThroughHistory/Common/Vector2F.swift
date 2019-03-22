//
//  Vector2F.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

struct Vector2F {
    static let zero = Vector2F(xCoord: 0, yCoord: 0)
    static let one = Vector2F(xCoord: 1, yCoord: 1)
    static let xAxis = Vector2F(xCoord: 1, yCoord: 0)
    static let yAxis = Vector2F(xCoord: 0, yCoord: 1)
    
    // randoms a direction vector
    static func random() -> Vector2F {
        var vector = Vector2F(xCoord: Float.random(), yCoord: Float.random())
        return vector.normalize()
    }
    
    static func - (lhs: Vector2F, rhs: Vector2F) -> Vector2F {
        return Vector2F(xCoord: lhs.xCoord - rhs.xCoord, yCoord: lhs.yCoord - rhs.yCoord)
    }
    
    static func + (lhs: Vector2F, rhs: Vector2F) -> Vector2F {
        return Vector2F(xCoord: lhs.xCoord + rhs.xCoord, yCoord: lhs.yCoord + rhs.yCoord)
    }
    
    static func * (lhs: Vector2F, rhs: Float) -> Vector2F {
        return Vector2F(xCoord: lhs.xCoord * rhs, yCoord: lhs.yCoord * rhs)
    }
    
    static func / (lhs: Vector2F, rhs: Float) -> Vector2F {
        return Vector2F(xCoord: lhs.xCoord / rhs, yCoord: lhs.yCoord / rhs)
    }
    
    var xCoord: Float
    var yCoord: Float
    
    var magnitude: Float {
        return (xCoord * xCoord + yCoord * yCoord).squareRoot()
    }
    
    @discardableResult
    mutating func normalize() -> Vector2F {
        let magnitude = self.magnitude
        if magnitude != 0 {
            xCoord /= magnitude
            yCoord /= magnitude
        }
        return self
    }
    
    mutating func add(other: Vector2F) {
        xCoord += other.xCoord
        yCoord += other.yCoord
    }
    
    func dot(other: Vector2F) -> Float {
        return xCoord * other.xCoord + yCoord * other.yCoord
    }
    
    func cross(other: Vector2F) -> Float {
        return xCoord * other.yCoord - yCoord * other.xCoord
    }
}
