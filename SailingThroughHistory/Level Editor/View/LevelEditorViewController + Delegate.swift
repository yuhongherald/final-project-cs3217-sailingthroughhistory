//
//  Level.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension LevelEditorViewController: EditPanelDelegateProtocol, UIGestureRecognizerDelegate {

    func clicked(_ select: EditMode) {
        editPanel.isHidden = true
        editMode = select
    }

    func addMap(_ image: UIImage) {
        mapBackground.image = image
    }
}
