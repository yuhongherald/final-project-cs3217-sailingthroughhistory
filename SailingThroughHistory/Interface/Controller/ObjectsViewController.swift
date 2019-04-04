//
//  ObjectsViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 21/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ObjectsViewController {
    private var objectViews = [GameObject: UIImageView]()
    private let mainController: MainGameViewController
    private var nodeViews = [Int: NodeView]()
    private var paths = ObjectPaths()
    private var pathLayers = [Path: CALayer]()
    private let view: UIView
    private var modelBounds: Rect {
        return mainController.interfaceBounds
    }

    init(view: UIView, mainController: MainGameViewController) {
        self.view = view
        self.mainController = mainController
    }

    func getFrame(for object: ReadOnlyGameObject) -> CGRect? {
        return nil
        //return views[ObjectIdentifier(object)]?.frame
    }

    func onTap(nodeView: NodeView) -> Int {
        if nodeView.node as? Port != nil {
            onTapPort(portView: nodeView)
        }

        return nodeView.node.identifier
    }

    func subscribeToNodes(in map: Map) {
        map.subscribeToNodes { [weak self] nodes in
            guard let self = self else {
                return
            }
            for node in nodes {
                if self.nodeViews[node.identifier] != nil {
                    continue
                }

                let nodeView = NodeView(node: node)
                nodeView.isUserInteractionEnabled = true
                nodeView.frame = CGRect.translatingFrom(otherBounds: self.modelBounds, otherFrame: node.frame,
                                                        to: self.view.bounds)
                nodeView.image = self.getImageFor(node: node)
                self.view.addSubview(nodeView)
                self.nodeViews[node.identifier] = nodeView
            }
        }
    }

    func subscribeToPaths(in map: Map) {
        map.subscribeToPaths { [weak self] nodePaths in
            let mapPaths = Set(nodePaths.values.flatMap { $0 })
            guard let existingPaths = self?.paths.allPaths else {
                return
            }

            for path in mapPaths {
                if existingPaths.contains(path) {
                    return
                }

                guard let fromFrame = self?.nodeViews[path.fromNode.identifier]?.frame,
                    let toFrame = self?.nodeViews[path.toNode.identifier]?.frame else {
                        continue
                }

                self?.paths.add(path: path)
                self?.addToView(path: path, from: fromFrame, to: toFrame, withDuration: 1)
            }
        }
    }

    func make(choosableNodes: [Int]) {
        for nodeId in choosableNodes {
            guard let view = nodeViews[nodeId] else {
                return
            }

            view.addGlow(colored: .yellow)
        }
    }

    func resetChoosableNodes() {
        nodeViews.values
            .forEach {
                $0.removeGlow()
        }
    }

    private func addToView(path: Path, from fromFrame: CGRect, to toFrame: CGRect, withDuration duration: TimeInterval) {
        let startPoint = CGPoint(x: fromFrame.midX, y: fromFrame.midY)
        let endPoint = CGPoint(x: toFrame.midX, y: toFrame.midY)
        let bezierPath = UIBezierPath()
        let layer = CAShapeLayer()
        bezierPath.move(to: startPoint)
        bezierPath.addLine(to: endPoint)
        layer.path = bezierPath.cgPath
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 4.0
        layer.lineDashPattern = [10.0, 2.0]
        view.layer.addSublayer(layer)
        pathLayers[path] = layer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = duration
        layer.add(animation, forKey: "drawLineAnimation")
    }

    /// TODO
    func subscribeToObjects(in map: Map) {
        map.subscribeToObjects { [weak self] in
            guard let self = self else {
                return
            }
            var objects = [GameObject](self.objectViews.keys)
            for object in $0 {
                if self.objectViews[object] != nil {
                    continue
                }
                let objectFrame = CGRect.translatingFrom(otherBounds: self.modelBounds,
                                                         otherFrame: object.frame.value, to: self.view.bounds)
                let objectView = UIImageView(frame: objectFrame)
                print(object.frame.value)
                print(objectView.frame)
                object.subscibeToFrame { frame in
                    UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                        let newFrame = CGRect.translatingFrom(otherBounds: self.modelBounds,
                                                              otherFrame: frame, to: self.view.bounds)
                        objectView.frame = newFrame
                    }, completion: nil)
                }
                if object as? ShipUI != nil {
                    objectView.image = UIImage(named: "ship.png")
                }
                self.objectViews[object] = objectView
                self.view.addSubview(objectView)
                objects.removeAll { $0 == object }
            }
            for removedObject in objects {
                let objectView = self.objectViews[removedObject]
                objectView?.removeFromSuperview()
                self.objectViews[removedObject] = nil
            }
        }
    }

    func updatePathWeather() {
        for path in paths.allPaths {
            /// TODO: Weather display
        }
    }

    private func getImageFor(node: Node) -> UIImage? {
        if node as? Sea != nil {
            return UIImage(named: "sea-node")
        } else if node as? Port != nil {
            return UIImage(named: "port-node")
        }

        return nil
    }

    private func onTapPort(portView: NodeView) {
        guard let port = portView.node as? Port else {
            return
        }

        mainController.showInformation(ofPort: port)
    }

    private enum State {
        case chooseDestination
        case normal
    }
}
