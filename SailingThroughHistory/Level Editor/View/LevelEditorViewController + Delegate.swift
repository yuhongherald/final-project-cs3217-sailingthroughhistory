//
//  Level.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension LevelEditorViewController: ItemPickerDelegateProtocol, EditPanelDelegateProtocol, UIGestureRecognizerDelegate {

    func pick(_ select: ItemType) {
        pickedItem = select
    }

    func clicked(_ select: EditMode) {
        editPanel.isHidden = true
        editMode = select
    }

    func addMap(_ image: UIImage) {
        mapBackground.image = image
    }

    func presentPicker(_ controller: UIViewController) {
        self.addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
}
