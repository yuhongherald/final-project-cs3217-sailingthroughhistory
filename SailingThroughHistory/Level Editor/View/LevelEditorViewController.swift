//
//  LevelEditorViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/17/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class LevelEditorViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 3
        }
    }
    @IBOutlet weak var editPanel: UIView!
    @IBOutlet weak var editingAreaWrapper: UIView!
    @IBOutlet weak var mapBackground: UIImageView!

    private var upgrades = [Upgrade]()
    private var playerParameters = [PlayerParameter]()
    private var eventParameters = [EventParameter]()
    private var map = Map()
    private let gameParameter = GameParameter()

    private var editMode: EditMode?
    private var pickedItem: ItemType?
    private var lineLayer = CAShapeLayer()
    private var destination: NodeView?

    private let storage = Storage()

    override var prefersStatusBarHidden: Bool {
        return true
    }

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
    }

    @IBAction func editPressed(_ sender: Any) {
        editPanel.isHidden = false
        view.bringSubviewToFront(editPanel)
    }

    @IBAction func savePressed(_ sender: Any) {
        let alert = UIAlert(title: "Save Level with Name: ", confirm: { name in
            storage.save(gameParameter, with: name)
        }, textPlaceHolder: "Input level name here")
        alert.present(in: self)
    }

    /// Add/Rmove icons to the map
    @objc func add(_ sender: UITapGestureRecognizer) {
        if editMode == .erase || editMode == .item {
            return
        }

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
            nodeView.addTo(self.editingAreaWrapper, map: self.map, with: [removeGesture, drawPathGesture])
        }, textPlaceHolder: "Input name here.")
        alert.present(in: self)
    }

    @objc func remove(_ sender: UITapGestureRecognizer) {
        if editMode == .erase {
            sender.view!.removeFromSuperview()
        }
        if editMode == .item {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "itemEditTable") as? ItemPickerViewController else {
                fatalError("Controller itemEditTable cannot be casted into ItemPickerViewController")
            }

            guard let portView = sender.view as? NodeView,
                let port = portView.node as? Port else {
                let alert = UIAlertController(title: "Please select a port!", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                return
            }

            controller.set(port: port, itemParameters: gameParameter.getItemParameter())
            self.addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
        }
    }

    @objc func drawPath(_ sender: UIPanGestureRecognizer) {
        guard editMode == .path else {
            return
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
            editingAreaWrapper.layer.addSublayer(lineLayer)
        case .changed:
            bazier.addLine(to: endPoint)
            lineLayer.path = bazier.cgPath

            destination?.highlighted(true)
        case .ended:
            fromNode.highlighted(false)
            destination?.highlighted(false)
            destination = nil

            guard let toNode = endView else {
                lineLayer.removeFromSuperlayer()
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

extension LevelEditorViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return editingAreaWrapper
    }
}
