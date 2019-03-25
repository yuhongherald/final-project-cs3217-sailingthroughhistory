//
//  Level.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension LevelEditorViewController: EditPanelDelegateProtocol {

    func clicked(_ select: EditMode) {
        editPanel.isHidden = true
        panelToggle.setTitle(showPanelMsg, for: .normal)
        view.sendSubviewToBack(editPanel)
        editMode = select
    }

    func addMapBackground(_ image: UIImage) {
        mapBackground.image = image
    }
}

extension LevelEditorViewController: GalleryViewDelegateProtocol {
    func load(_ gameParameter: GameParameter) {
        self.gameParameter = gameParameter
    }
}

extension LevelEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return editingAreaWrapper
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        playerMenu.isHidden = true
    }
}

extension LevelEditorViewController: MenuViewDelegateProtocol {
    func assign(port: Port, to player: PlayerParameter) {
        player.assign(port: port)
        playerMenu.isHidden = true
    }
}
