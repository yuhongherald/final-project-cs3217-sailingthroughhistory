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
    @IBOutlet weak var playerMenu: UIView!
    @IBOutlet weak var editingAreaWrapper: UIView!
    @IBOutlet weak var mapBackground: UIImageView!
    @IBOutlet weak var panelToggle: UIButton!
    private var panelDest: EditPanelViewController?
    private var menuDest: MenuViewController?
    var showPanelMsg = "Show Panel"
    var hidePanelMsg = "Hide Panel"

    var gameParameter = GameParameter(numOfPlayer: 2)

    var editMode: EditMode?
    private var lineLayer = CAShapeLayer()
    private var startingNode: NodeView?
    private var destination: NodeView?

    private let storage = Storage()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toEditPanel":
            guard let panelDest = segue.destination as? EditPanelViewController else {
                return
            }
            panelDest.delegate = self
            self.panelDest = panelDest
        case "toPlayerMenu":
            guard let menuDest = segue.destination as? MenuViewController else {
                return
            }
            menuDest.delegate = self
            self.menuDest = menuDest
        case "toGallary":
            guard let gallaryDest = segue.destination as? GalleryViewController else {
                return
            }
            gallaryDest.delegate = self
        default:
            guard let gallaryDest = segue.destination as? GalleryViewController else {
                return
            }
            gallaryDest.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        menuDest?.data = gameParameter.getPlayerParameters()
        playerMenu.isUserInteractionEnabled = true

        let map = gameParameter.getMap()
        // Add nodes to map
        map.getNodes().forEach {
            let nodeView = NodeView(node: $0)
            nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.getMap(), with: initNodeGestures())
        }
        // Add paths to map
        for path in map.getAllPaths() {
            print("\(map.getAllPaths().count) - from: \(path.fromObject.frame) - to: \(path.toObject.frame)")
            lineLayer = CAShapeLayer()
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.lineWidth = 2.0

            let bazier = UIBezierPath()
            bazier.move(to: CGPoint(x: path.fromObject.frame.midX,
                                    y: path.fromObject.frame.midY))
            bazier.addLine(to: CGPoint(x: path.toObject.frame.midX,
                                       y: path.toObject.frame.midY))

            lineLayer.path = bazier.cgPath
            editingAreaWrapper.layer.addSublayer(lineLayer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reInitScrollView()
        initBackground()
        playerMenu.frame.size = CGSize(width: 200, height: 100)
        playerMenu.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnMap(_:)))
        editingAreaWrapper.addGestureRecognizer(tapGesture)
    }

    @IBAction func editPressed(_ sender: Any) {
        if editPanel.isHidden {
            editPanel.isHidden = false
            panelToggle.setTitle(hidePanelMsg, for: .normal)
            view.bringSubviewToFront(editPanel)
        } else {
            editPanel.isHidden = true
            panelToggle.setTitle(showPanelMsg, for: .normal)
            view.sendSubviewToBack(editPanel)
        }
    }

    @IBAction func savePressed(_ sender: Any) {
        let alert = UIAlert(title: "Save Level with Name: ", confirm: { name in
            self.gameParameter.getMap().addMap("\(name)background")
            self.storage.save(self.gameParameter, self.mapBackground.image,
                              preview: self.editingAreaWrapper.screenShot, with: name)
        }, textPlaceHolder: "Input level name here")
        alert.present(in: self)
    }

    @objc func tapOnMap(_ sender: UITapGestureRecognizer) {
        if editMode == .erase || editMode == .item {
            return
        }

        if !editPanel.isHidden {
            return
        }

        let location = sender.location(in: self.mapBackground)

        let alert = UIAlert(title: "Input name: ", confirm: { ownerName in
            guard let nodeView = self.editMode?.getNodeView(name: ownerName, at: location) else {
                return
            }
            nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.getMap(), with: self.initNodeGestures())
        }, textPlaceHolder: "Input name here.")
        alert.present(in: self)
    }

    @objc func singleTapOnNode(_ sender: UITapGestureRecognizer) {
        if editMode == .erase {
            guard let nodeView = sender.view as? NodeView else {
                return
            }
            nodeView.removeFrom(map: self.gameParameter.getMap())
        }
        if editMode == .item {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "itemEditTable")
                as? ItemCollectionViewController else {
                fatalError("Controller itemEditTable cannot be casted into ItemCollectionViewController")
            }

            guard let portView = sender.view as? NodeView,
                let port = portView.node as? Port else {
                let alert = UIAlertController(title: "Please select a port!", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                return
            }

            _ = controller.view
            controller.initWith(port: port)

            self.addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
        }
    }

    @objc func doubleTapOnNode(_ sender: UITapGestureRecognizer) {
        guard let node = sender.view as? NodeView, let port = node.node as? Port else {
            let alert = UIAlert(errorMsg: "Double click on port to assign ownership.", msg: nil)
            alert.present(in: self)
            return
        }

        if playerMenu.isHidden {
            UIView.animate(withDuration: 0, animations: {
                let point = node.convert(CGPoint(x: node.bounds.maxX, y: node.bounds.maxY), to: self.view)
                self.playerMenu.frame.origin = point
            })
            playerMenu.isHidden = false
        } else {
            playerMenu.isHidden = true
        }

        menuDest?.set(port: port)
    }

    @objc func drawPath(_ sender: UIPanGestureRecognizer) {
        guard editMode == .path else {
            return
        }

        guard let fromNode = sender.view as? NodeView else {
            return
        }
        startingNode = fromNode

        let endPoint = sender.location(in: mapBackground)
        let endView = view.hitTest(endPoint, with: nil) as? NodeView
        if endView != nil {
            destination = endView
            destination?.highlighted(true)
        } else {
            destination?.highlighted(false)
            destination = nil
        }
        let bazier = UIBezierPath()
        bazier.move(to: fromNode.center)

        switch sender.state {
        case .began:
            lineLayer = CAShapeLayer()
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.lineWidth = 2.0

            startingNode?.highlighted(true)
            editingAreaWrapper.layer.addSublayer(lineLayer)
        case .changed:
            bazier.addLine(to: endPoint)
            lineLayer.path = bazier.cgPath
        case .ended:
            startingNode?.highlighted(false)
            destination?.highlighted(false)
            destination = nil

            guard let toNode = endView else {
                lineLayer.removeFromSuperlayer()
                return
            }

            bazier.addLine(to: toNode.center)

            gameParameter.getMap().add(path: Path(from: fromNode.node, to: toNode.node))
            lineLayer.path = bazier.cgPath
        default:
            return
        }
    }

    private func initBackground() {
        guard let image = UIImage(named: "worldmap1815"),
            let editingAreaWrapper = self.editingAreaWrapper else {
                return
        }

        mapBackground.contentMode = .topLeft
        mapBackground.frame = CGRect(origin: CGPoint.zero, size: image.size)
        editingAreaWrapper.frame = mapBackground.frame
        editingAreaWrapper.subviews.forEach {
            $0.frame = mapBackground.frame
        }

        scrollView.contentSize = image.size
        scrollView.minimumZoomScale = max(view.frame.height/image.size.height, view.frame.width/image.size.width)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        mapBackground.image = image
    }

    private func reInitScrollView () {
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

    private func initNodeGestures() -> [UIGestureRecognizer] {
        let singleTapOnNodeGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapOnNode(_:)))
        singleTapOnNodeGesture.numberOfTapsRequired = 1
        let doubleTapOnNodeGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapOnNode(_:)))
        doubleTapOnNodeGesture.numberOfTapsRequired = 2

        singleTapOnNodeGesture.require(toFail: doubleTapOnNodeGesture)
        singleTapOnNodeGesture.delaysTouchesBegan = true
        doubleTapOnNodeGesture.delaysTouchesBegan = true

        let drawPathGesture = UIPanGestureRecognizer(target: self, action: #selector(drawPath(_:)))

        return [singleTapOnNodeGesture, doubleTapOnNodeGesture, drawPathGesture]
    }

    private func fillWith(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
