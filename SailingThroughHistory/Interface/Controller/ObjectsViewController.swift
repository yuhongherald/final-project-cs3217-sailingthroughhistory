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
    private var nodeViews = [Node: UIImageView]()
    private var paths = ObjectPaths()
    private var pathLayers = [Path: CALayer]()
    private let view: UIView

    init(view: UIView, mainController: MainGameViewController) {
        self.view = view
        self.mainController = mainController
    }

    func getFrame(for object: ReadOnlyGameObject) -> CGRect? {
        return nil
        //return views[ObjectIdentifier(object)]?.frame
    }

    func onTap(objectView: UIGameObjectImageView) {
        if objectView.tapCallback != nil,
            objectView.object as? Node != nil {
                onTapChoosableNode(nodeView: objectView)
                return
        }

        if objectView.object as? Port != nil {
            onTapPort(portView: objectView)
            return
        }
    }

    func subscribeToNodes(in map: Map) {
        map.subscribeToNodes { [weak self] nodes in
            for node in nodes {
                if self?.nodeViews[node] != nil {
                    continue
                }

                let nodeView = UIImageView(frame: CGRect(fromRect: node.frame))
                nodeView.image = self?.getImageFor(node: node)
                self?.view.addSubview(nodeView)
                self?.nodeViews[node] = nodeView
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

                guard let fromFrame = self?.nodeViews[path.fromNode]?.frame,
                    let toFrame = self?.nodeViews[path.toNode]?.frame else {
                        continue
                }

                self?.paths.add(path: path)
                self?.addToView(path: path, from: fromFrame, to: toFrame, withDuration: 1)
            }
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
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = duration
        layer.add(animation, forKey: "drawLineAnimation")
        CATransaction.commit()
    }

    /// TODO
    func subscribeToObjects(in map: Map) {
        map.subscribeToObjects { [weak self] in
            for object in $0 {
                print("HERE")
                print(object.frame.value)
                if self?.objectViews[object] != nil {
                    continue
                }

                let objectView = UIImageView(frame: CGRect(fromRect: object.frame.value))
                object.subscibeToFrame { frame in
                    UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
                        objectView.frame = CGRect(fromRect: frame)
                    }, completion: nil)
                }
                if object as? ShipUI != nil {
                    objectView.image = UIImage(named: "ship.png")
                }
                self?.objectViews[object] = objectView
                self?.view.addSubview(objectView)
            }
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

    private func onTapChoosableNode(nodeView: UIGameObjectImageView) {
        /*guard nodeView.tapCallback != nil,
            nodeView.object as? Node != nil else {
            return
        }

        nodeView.callTapCallback()

        // Remove glow/callback from nodes.
        views.values
            .filter { $0.object as? Node != nil }
            .forEach {
                $0.removeGlow()
                $0.tapCallback = nil
        }*/
    }

    private func onTapPort(portView: UIGameObjectImageView) {
        guard let port = portView.object as? Port else {
            return
        }

        mainController.showInformation(ofPort: port)
    }

    func add(object: ReadOnlyGameObject, at frame: Rect, withDuration duration: TimeInterval,
                      callback: @escaping () -> Void) {
        /*let objectIdentifier = ObjectIdentifier(object)
        views[objectIdentifier]?.removeFromSuperview()
        let image = UIImage(named: object.image)
        let view = UIGameObjectImageView(image: image, object: object)
        if object.isAnimated {
            view.animationImages = object.images
                .rotatedLeft(
                    by: UInt(object.startingFrame))
                .compactMap { UIImage(named: $0 )}
            view.animationDuration = object.loopDuration
            view.startAnimating()
        }
        views[objectIdentifier] = view
        view.alpha = 0
        self.view.addSubview(view)
        view.frame = CGRect.translatingFrom(otherBounds: mainController.interfaceBounds,
                                            otherFrame: CGRect(fromRect: frame), to: self.view.bounds)
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: { _ in callback() })*/
    }

    func remove(object: ReadOnlyGameObject, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        /*guard let view = views.removeValue(forKey: ObjectIdentifier(object)) else {
            callback()
            return
        }

        view.fadeOutAndRemove(withDuration: duration, completion: callback)*/
    }

    func makeChoosable(nodes: [Node], withDuration duration: TimeInterval, tapCallback: @escaping (ReadOnlyGameObject) -> Void, callback: @escaping () -> Void) {
        /*
        if nodes.isEmpty {
            callback()
            return
        }

        let views = self.views

        for node in nodes {
            let nodeKey = ObjectIdentifier(node)
            views[nodeKey]?.isUserInteractionEnabled = true
            views[nodeKey]?.tapCallback = tapCallback
        }

        UIView.animate(withDuration: duration, animations: {
            nodes.forEach {
                views[ObjectIdentifier($0)]?.addGlow(colored: .purple)
            }
        }, completion: { _ in
            callback()
        })*/
    }

    func move(object: ReadOnlyGameObject, to dest: Rect, withDuration duration: TimeInterval,
              callback: @escaping () -> Void) {
        /*guard let objectView = views[ObjectIdentifier(object)] else {
            return
        }

        let mainController = self.mainController
        let bounds = view.bounds

        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            objectView.frame = CGRect.translatingFrom(otherBounds: mainController.interfaceBounds,
                                                      otherFrame: CGRect(fromRect: dest),
                                                      to: bounds)
            }, completion: { _ in callback() })*/
    }
}
