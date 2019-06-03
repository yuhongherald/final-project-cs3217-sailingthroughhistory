//
//  LevelEditorViewController + Layout.swift
//  SailingThroughHistory
//
//  Created by ysq on 4/18/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension LevelEditorViewController {
    func showPanel() {
        editPanel.isHidden = false
        panelToggle.setTitle(hidePanelMsg, for: .normal)
        view.bringSubviewToFront(editPanel)
    }

    func hidePanel() {
        editPanel.isHidden = true
        panelToggle.setTitle(showPanelMsg, for: .normal)
        view.sendSubviewToBack(editPanel)
    }

    func hideTeamMenu() {
        UIView.transition(with: teamMenu, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.teamMenu.alpha = 0
        }, completion: { _ in
            self.teamMenu.isHidden = true
            self.teamMenu.alpha = 1
        })
    }

    /// Update views with updated game parameter.
    func reInit() {
        reInitScrollView()
        initBackground()

        let map = gameParameter.map
        let teams = gameParameter.teams
        let teamStartIds = teams.map { $0.startId }
        // remove All nodes / paths
        self.editingAreaWrapper.subviews.filter { $0 is NodeView }
            .forEach { $0.removeFromSuperview() }
        self.editingAreaWrapper.layer.sublayers?.filter { $0 is PathView }
            .forEach { $0.removeFromSuperlayer() }
        // Add nodes to map
        map.getNodes().forEach { node in
            let nodeView = NodeView(node: node)
            nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.map, with: initNodeGestures())
            if let teamIndex = teamStartIds.firstIndex(of: node.identifier) {
                let team = teams[teamIndex]
                team.startingNode = node
                if let icon = getIconOf(team: teams[teamIndex]) {
                    icon.addIcon(to: nodeView)
                }
            }
        }
        // Add paths to map
        for path in map.getAllPaths() {
            lineLayer = PathView(path: path)
            editingAreaWrapper.layer.addSublayer(lineLayer)
            lineLayerArr.append(lineLayer)
        }
    }

    /// Set up background of the map.
    /// Load image of background and layout it.
    func initBackground() {
        guard let image = storage.readImage(gameParameter.map.map) ?? UIImage(named: gameParameter.map.map) else {
            return
        }
        mapBackground.image = image
        layoutBackground()
    }

    /// Layout background with its image size.
    func layoutBackground() {
        guard let image = mapBackground.image, let editingAreaWrapper = self.editingAreaWrapper else {
            return
        }
        mapBackground.contentMode = .topLeft
        var size = image.size
        if size.width < self.view.frame.width {
            let width = self.view.frame.width
            let height = size.height / size.width * width
            size = CGSize(width: width, height: height)
        }
        mapBackground.frame = CGRect(origin: CGPoint.zero, size: size)
        editingAreaWrapper.frame = mapBackground.frame

        scrollView.contentSize = size
        scrollView.minimumZoomScale = max(view.frame.height/size.height, view.frame.width/size.width)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        mapBackground.image = image
    }

    /// Reinitializes the scroll view to allow for size changes.
    func reInitScrollView () {
        guard let oldScrollView = self.scrollView else {
            preconditionFailure("scrollView is nil.")
        }

        let scrollView = UIScrollView(frame: self.scrollView.frame)
        self.scrollView = scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(scrollView, aboveSubview: oldScrollView)
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.updateConstraints()
        editingAreaWrapper.removeFromSuperview()
        scrollView.addSubview(editingAreaWrapper)
    }

    /// Add required gestures to node.
    func initNodeGestures() -> [UIGestureRecognizer] {
        let singleTapOnNodeGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapOnNode(_:)))
        singleTapOnNodeGesture.numberOfTapsRequired = 1
        let doubleTapOnNodeGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapOnNode(_:)))
        doubleTapOnNodeGesture.numberOfTapsRequired = 2
        let longPressOnNodeGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnNode(_:)))

        singleTapOnNodeGesture.require(toFail: doubleTapOnNodeGesture)
        singleTapOnNodeGesture.delaysTouchesBegan = true
        doubleTapOnNodeGesture.delaysTouchesBegan = true

        let drawPathGesture = UIPanGestureRecognizer(target: self, action: #selector(drawPath(_:)))

        return [singleTapOnNodeGesture, doubleTapOnNodeGesture, longPressOnNodeGesture, drawPathGesture]
    }
}
