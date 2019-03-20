//
//  LevelEditorViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/17/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class LevelEditorViewController: UIViewController {
    @IBOutlet weak var editPanel: UIView!
    @IBOutlet weak var mapBackground: UIImageView!
    let map = Map()
    let gameParameter = GameParameter()
    var editMode: EditMode?
    var pickedItem: ItemType?
    var lineLayer: CAShapeLayer!
    var destination: NodeView?
    var cursor = UILabel()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let castedDest = segue.destination as? EditPanelViewController else {
            return
        }
        castedDest.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(add(_:)))
        view.addGestureRecognizer(tapGesture)

        let image = UIImage(named: "worldmap1815")
        mapBackground.image = image
        map.addMap(mapBackground)

        cursor.frame.size = CGSize(width: 50, height: 50)
        view.addSubview(cursor)
    }

    @IBAction func editPressed(_ sender: Any) {
        editPanel.isHidden = false
        view.bringSubviewToFront(editPanel)
    }

    @IBAction func savePressed(_ sender: Any) {
        let alert = UIAlert(title: "Save Level with Name: ", confirm: { _ in
            //TODO: save level with name
        }, textPlaceHolder: "Input level name here")
        alert.present(in: self)
    }

    /// Add/Rmove icons to the map
    @objc func add(_ sender: UITapGestureRecognizer) {
        if !editPanel.isHidden {
            return
        }

        let removeGesture = UITapGestureRecognizer(target: self, action: #selector(remove(_:)))
        let drawPathGesture = UIPanGestureRecognizer(target: self, action: #selector(drawPath(_:)))
        let location = sender.location(in: self.mapBackground)

        let alert = UIAlert(title: "Input name: ", confirm: { ownerName in
            guard let nodeView = self.editMode?.getNodeView(name: ownerName, at: location) else {
                return
            }
            nodeView.addTo(self, map: self.map, with: [removeGesture, drawPathGesture])
        }, textPlaceHolder: "Input name here.")
        alert.present(in: self)
    }

    @objc func remove(_ sender: UITapGestureRecognizer) {
        if editMode == .erase {
            sender.view!.removeFromSuperview()
        }
    }

    @objc func drawPath(_ sender: UIPanGestureRecognizer) {
        guard editMode == .path || editMode == .item else {
            return
        }

        if editMode == .item {
            cursor.text = pickedItem?.rawValue
            cursor.center = sender.location(in: mapBackground)
        }

        guard let fromNode = sender.view as? NodeView else {
            return
        }

        let endPoint = sender.location(in: mapBackground)
        let endView = view.hitTest(endPoint, with: nil) as? NodeView
        if endView != nil {
            destination = endView
        }
        let bazier = UIBezierPath()
        bazier.move(to: fromNode.center)

        switch sender.state {
        case .began:
            lineLayer = CAShapeLayer()
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.lineWidth = 2.0

            fromNode.highlighted(true)
            mapBackground.layer.addSublayer(lineLayer)
        case .changed:
            bazier.addLine(to: endPoint)
            lineLayer.path = bazier.cgPath

            destination?.highlighted(true)
        case .ended:
            fromNode.highlighted(false)
            destination?.highlighted(false)
            destination = nil

            // TODO: a better way to delocate cursor
            cursor.text = ""

            guard let toNode = endView else {
                lineLayer.removeFromSuperlayer()
                return
            }

            if editMode == .item, let to = toNode.node as? Port, let from = fromNode.node as? Port {
                let alert = UIAlert(title: "Input export money to: ", confirm: { money in
                    // TODO: add item value
                    //gameParameter.add
                }, textPlaceHolder: "100")
                alert.present(in: self)
                return
            }

            bazier.addLine(to: toNode.center)

            map.add(path: Path(from: fromNode.node, to: toNode.node))
            lineLayer.path = bazier.cgPath
        default:
            return
        }
    }
}
