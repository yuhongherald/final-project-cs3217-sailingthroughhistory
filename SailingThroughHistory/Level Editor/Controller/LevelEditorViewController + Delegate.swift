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
        hidePanel()
        editMode = select
    }

    func addMapBackground(_ image: UIImage) {
        mapBackground.image = image
        layoutBackground()
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
        hideTeamMenu()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideTeamMenu()
    }
}

extension LevelEditorViewController: MenuViewDelegateProtocol {
    func assign(port: Port, to team: Team?) {
        teamMenu.isHidden = true
        port.assignOwner(team)
    }

    func start(from node: Node, for team: Team) {
        teamMenu.isHidden = true
        let preStartingNode = team.startingNode
        team.startingNode = node
        self.editingAreaWrapper.subviews.forEach { view in
            guard let nodeView = view as? NodeView else {
                return
            }
            if nodeView.node == preStartingNode {
                nodeView.subviews.forEach {
                    if $0 is Icon {
                        $0.removeFromSuperview()
                    }
                }
            }
            if team.startingNode == nodeView.node, let shipIcon = getIconOf(team: team) {
                shipIcon.addIcon(to: nodeView)
            }
        }
    }

    func getEditingMode(for gesture: UIGestureRecognizer) -> EditMode? {
        switch gesture {
        case is UITapGestureRecognizer:
            return .portOwnership
        case is UILongPressGestureRecognizer:
            return .startingNode
        default:
            return nil
        }
    }

    func getIconOf(team: Team) -> Icon? {
        let view = Icon(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        switch team.name {
        case GameConstants.dutchTeam:
            view.image = UIImage(named: Resources.Flag.dutch)
        case GameConstants.britishTeam:
            view.image = UIImage(named: Resources.Flag.british)
        default:
            return nil
        }
        return view
    }
}
