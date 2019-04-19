//
//  UIImageView+Icon.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/16/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Icon: UIImageView {
    /// Add icon on right bottom of the UIView.
    /// - Parameters:
    ///   - view: The UIView where icon is to be added into.
    func addIcon(to view: UIView) {
        guard let image = self.image else {
            return
        }
        view.addSubview(self)
        let width = view.frame.width / 2
        let height = (image.size.height / image.size.width) * width
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
