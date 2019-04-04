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
        reInit()
    }
}

extension LevelEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return editingAreaWrapper
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        UIView.transition(with: playerMenu, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.playerMenu.alpha = 0
        }, completion: { _ in
            self.playerMenu.isHidden = true
            self.playerMenu.alpha = 1
        })
    }
}

extension LevelEditorViewController: MenuViewDelegateProtocol {
    func assign(port: Port, to team: Team?) {
        playerMenu.isHidden = true
        port.assignOwner(team)
    }
}
