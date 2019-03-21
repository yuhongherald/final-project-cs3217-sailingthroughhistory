//
//  GameObject.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 16/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class GameObject {
    var image: String
    var frame: CGRect
    var icon: UIImageView

    init(image: String, frame: CGRect) {
        self.image = image
        self.frame = frame
        self.icon = UIImageView(image: UIImage(named: image))
        icon.frame = frame
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
