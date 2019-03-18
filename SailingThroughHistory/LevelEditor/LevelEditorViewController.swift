//
//  LevelEditorViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/17/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class LevelEditorViewController: UIViewController, EditPanelDelegateProtocol, UIGestureRecognizerDelegate {
    @IBOutlet weak var editPanel: UIView!
    @IBOutlet weak var map: UIImageView!
    var editObject: EditableObject?
    var lineLayer: CAShapeLayer!
    var destination: UIImageView?

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

        let image = UIImage(named: Interface().background)
        map.image = image
    }

    @IBAction func editPressed(_ sender: Any) {
        editPanel.isHidden = false
        view.bringSubviewToFront(editPanel)
    }

    @IBAction func savePressed(_ sender: Any) {
        let alert = UIAlertController(title: "Save Level with Name: ", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default,
                                       handler: { _ in
                                        guard let fileName = alert.textFields?.first?.text else {
                                            return
                                        }
                                        //TODO: save level with name
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addTextField { (textFiled: UITextField) in
            textFiled.keyboardAppearance = .default
            textFiled.keyboardType = .default
            textFiled.placeholder = "Input level name here"
            textFiled.clearButtonMode = .whileEditing
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }

    /// Add/Rmove icons to the map
    @objc func add(_ sender: UITapGestureRecognizer) {
        if !editPanel.isHidden, editObject != .erase {
            return
        }

        let addedObject = editObject?.getObject(at: sender.location(in: map))

        let removeGesture = UITapGestureRecognizer(target: self, action: #selector(remove(_:)))
        let drawPathGesture = UIPanGestureRecognizer(target: self, action: #selector(drawPath(_:)))

        addedObject?.addNodeTo(self.view, with: removeGesture, drawPathGesture)
    }

    @objc func remove(_ sender: UITapGestureRecognizer) {
        if editObject == .erase {
            sender.view!.removeFromSuperview()
        }
    }

    @objc func drawPath(_ sender: UIPanGestureRecognizer) {
        guard editObject == .path else {
            return
        }
        let endPoint = sender.location(in: map)
        let endView = view.hitTest(endPoint, with: nil) as? UIImageView
        if endView != map, endView != nil {
            destination = endView
        }
        let bazier = UIBezierPath()
        bazier.move(to: (sender.view?.center)!)

        switch sender.state {
        case .began:
            lineLayer = CAShapeLayer()
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.lineWidth = 2.0

            sender.view?.layer.borderColor = UIColor.white.cgColor
            sender.view?.layer.borderWidth = 3.0
            map.layer.addSublayer(lineLayer)
        case .changed:
            bazier.addLine(to: endPoint)
            lineLayer.path = bazier.cgPath

            destination?.layer.borderColor = UIColor.white.cgColor
            destination?.layer.borderWidth = 3.0
        case .ended:
            sender.view?.layer.borderWidth = 0
            destination?.layer.borderWidth = 0
            destination = nil

            guard endView != nil else {
                lineLayer.removeFromSuperlayer()
                return
            }

            bazier.addLine(to: (endView?.center)!)
            lineLayer.path = bazier.cgPath
        default:
            return
        }
    }

    func clicked(_ select: EditableObject) {
        editPanel.isHidden = true
        editObject = select
    }
}
