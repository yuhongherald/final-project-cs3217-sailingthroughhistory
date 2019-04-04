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

    var gameParameter: GameParameter = {
        let imageName = Default.Background.image
        var bounds: Rect?
        if let image = UIImage(named: imageName) {
            bounds = Rect(originX: 0, originY: 0, height: Double(image.size.height), width: Double(image.size.width))
        }

        let map = Map(map: imageName, bounds: bounds)
        return GameParameter(map: map, teams: ["Dutch", "British"])
    }()

    var editMode: EditMode?
    private var lineLayerArr = [PathView]()
    private var lineLayer = PathView()
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
            gallaryDest.selectedCallback = { loadedParameter in
                self.load(loadedParameter)
            }
            gallaryDest.delegate = self
        default:
            return
        }
    }

    func reInit() {
        initBackground()

        menuDest?.data = gameParameter.teams
        playerMenu.isUserInteractionEnabled = true

        let map = gameParameter.map
        // remove All nodes / paths
        self.editingAreaWrapper.subviews.filter { $0 is NodeView }
            .forEach { $0.removeFromSuperview() }
        self.editingAreaWrapper.layer.sublayers?.filter { $0 is PathView }
            .forEach { $0.removeFromSuperlayer() }
        // Add nodes to map
        map.getNodes().forEach {
            let nodeView = NodeView(node: $0)
            nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.map, with: initNodeGestures())
        }
        // Add paths to map
        for path in map.getAllPaths() {
            lineLayer = PathView()
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.lineWidth = 2.0

            let bazier = UIBezierPath()
            bazier.move(to: CGPoint(x: path.fromNode.frame.midX,
                                    y: path.fromNode.frame.midY))
            bazier.addLine(to: CGPoint(x: path.toNode.frame.midX,
                                       y: path.toNode.frame.midY))

            lineLayer.path = bazier.cgPath
            lineLayer.set(from: path.fromNode, to: path.toNode)
            editingAreaWrapper.layer.addSublayer(lineLayer)
            lineLayerArr.append(lineLayer)
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
            var bounds = Rect(originX: 0, originY: 0,
                              height: Double(self.view.bounds.size.height),
                              width: Double(self.view.bounds.size.width))
            if let size = self.mapBackground.image?.size {
                bounds = Rect(originX: 0, originY: 0, height: Double(size.height), width: Double(size.width))
            }
            self.gameParameter.map.changeBackground("\(name)background", with: bounds)
            self.storage.save(self.gameParameter, self.mapBackground.image,
                              preview: self.scrollView.screenShot, with: name)
        }, textPlaceHolder: "Input level name here")
        alert.present(in: self)
    }

    @objc func tapOnMap(_ sender: UITapGestureRecognizer) {
        if editMode == .erase || editMode == .item || editMode == .pirate {
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
            nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.map, with: self.initNodeGestures())
        }, textPlaceHolder: "Input name here.")
        alert.present(in: self)
    }

    @objc func singleTapOnNode(_ sender: UITapGestureRecognizer) {
        if editMode == .erase {
            guard let nodeView = sender.view as? NodeView else {
                return
            }
            nodeView.removeFrom(map: self.gameParameter.map)
            var offset = 0
            for (index, lineLayer) in lineLayerArr.enumerated() {
                if lineLayer.fromNodeView == nodeView.node
                    || lineLayer.toNodeView == nodeView.node {
                    lineLayerArr.remove(at: index - offset)
                    lineLayer.removeFromSuperlayer()
                    offset+=1
                }
            }
        }
        if editMode == .item {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "itemEditTable")
                as? ItemCollectionViewController else {
                fatalError("Controller itemEditTable cannot be casted into ItemCollectionViewController")
            }

            guard let portView = sender.view as? NodeView,
                let port = portView.node as? Port else {
                let alert = UIAlert(errorMsg: "Please select a port!", msg: nil)
                alert.present(in: self)
                return
            }

            _ = controller.view
            controller.initWith(port: port)

            self.addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
        }

        if editMode == .pirate {
            guard let nodeView = sender.view as? NodeView else {
                let alert = UIAlert(errorMsg: "Please select a node!", msg: nil)
                alert.present(in: self)
                return
            }
            if nodeView.node is Port {
                let alert = UIAlert(errorMsg: "You cannot add pirate to a port!", msg: nil)
                alert.present(in: self)
                return
            }

            let pirate = Pirate(in: nodeView.node)
            nodeView.node.add(object: pirate)
            nodeView.update()
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
        let endView = editingAreaWrapper.hitTest(endPoint, with: nil) as? NodeView
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
            lineLayer = PathView()
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
            lineLayer.set(from: fromNode.node, to: toNode.node)

            gameParameter.map.add(path: Path(from: fromNode.node, to: toNode.node))
            lineLayer.path = bazier.cgPath
            lineLayerArr.append(lineLayer)
        default:
            return
        }
    }

    private func initBackground() {
        guard let image = storage.readImage(gameParameter.map.map) ?? UIImage(named: gameParameter.map.map),
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
