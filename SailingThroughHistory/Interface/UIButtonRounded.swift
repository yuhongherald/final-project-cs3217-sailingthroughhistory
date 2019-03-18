//
//  UIButtonRounded.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UIButtonRounded: UIButton {
    private static let contentEdgeInsets = UIEdgeInsets(top: 5, left: 40, bottom: 5, right: 0)
    private static let titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 20)
    private static let borderWidth: CGFloat = 1
    private static let cornerRadius: CGFloat = 20
    private static let backgroundColor = UIColor.white
    static let defaultColor = UIColor(red: 0.10, green: 0.47, blue: 0.98, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        roundEdges()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        roundEdges()
    }

    private func roundEdges() {
        layer.cornerRadius = UIButtonRounded.cornerRadius
        borderWidth = UIButtonRounded.borderWidth
        borderColor = UIButtonRounded.defaultColor
        contentEdgeInsets = UIButtonRounded.contentEdgeInsets
        titleEdgeInsets = UIButtonRounded.titleEdgeInsets
        backgroundColor = UIButtonRounded.backgroundColor
    }

    func set(color: UIColor) {
        setTitleColor(color, for: .normal)
        borderColor = color
    }
}
