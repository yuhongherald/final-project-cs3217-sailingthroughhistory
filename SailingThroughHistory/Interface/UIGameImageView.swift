//
//  UIGameImageView.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UIGameImageView: UIImageView {
    let object: GameObject
    var tapCallback: ((GameObject) -> Void)?

    init(image: UIImage?, object: GameObject) {
        self.object = object
        super.init(image: image)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Decode has not been implemented.")
    }

    func callTapCallback() {
        tapCallback?(object)
    }
}
