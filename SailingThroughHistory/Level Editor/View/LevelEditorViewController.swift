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
    @IBOutlet weak var teamMenu: UIView!
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
        return GameParameter(map: map, teams: [GameConstants.dutchTeam, GameConstants.britishTeam])
    }()

    var editMode: EditMode?
    private var lineLayerArr = [PathView]()
    private var lineLayer = PathView()
    private var startingNode: NodeView?
    private var destination: NodeView?

    private let storage = LocalStorage()

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
            menuDest.data = gameParameter.teams
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
        reInitScrollView()
        initBackground()

        menuDest?.data = gameParameter.teams
        teamMenu.isUserInteractionEnabled = true

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

    override func viewDidLoad() {
        super.viewDidLoad()

        reInitScrollView()
        initBackground()

        teamMenu.frame.size = CGSize(width: 200, height: 100)
        teamMenu.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnMap(_:)))
        editingAreaWrapper.addGestureRecognizer(tapGesture)
    }

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
            self.store(with: name)
        }, textPlaceHolder: "Input level name here")
        alert.present(in: self)
    }

    @objc func tapOnMap(_ sender: UITapGestureRecognizer) {
        guard editMode != nil else {
            return
        }

        if !editPanel.isHidden {
            return
        }

        let location = sender.location(in: self.mapBackground)

        if editMode == .erase {
            var removed = 0
            for (index, path) in self.lineLayerArr.enumerated() {
                if self.isPoint(point: location, withinDistance: 20, ofPath: path.path) {
                    self.lineLayerArr.remove(at: index - removed)
                    removed += 1
                    path.removeFromSuperlayer()

                    guard let path = path.shipPath else {
                        return
                    }
                    self.gameParameter.map.removePath(path)
                }
            }
            return
        }

        if editMode == .weather {
            self.lineLayerArr.forEach { path in
                if self.isPoint(point: location, withinDistance: 20, ofPath: path.path) {
                    path.add(Weather())
                }
            }
            return
        }

        if editMode == .sea || editMode == .port {
            let alert = UIAlert(title: "Input name: ", confirm: { ownerName in
                guard let nodeView = self.editMode?.getNodeView(name: ownerName, at: location) else {
                    return
                }
                nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.map, with: self.initNodeGestures())
            }, textPlaceHolder: "Input name here.")
            alert.present(in: self)
        }
    }

    final func isPoint(point: CGPoint, withinDistance distance: CGFloat, ofPath path: CGPath?) -> Bool {
        guard let castedPath = path else {
            return false
        }

        if let hitPath = CGPath( __byStroking: castedPath,
                                 transform: nil,
                                 lineWidth: distance,
                                 lineCap: CGLineCap.round,
                                 lineJoin: CGLineJoin.miter,
                                 miterLimit: 0) {

            let isWithinDistance = hitPath.contains(point)
            return isWithinDistance
        }
        return false
    }

    @objc func singleTapOnNode(_ sender: UITapGestureRecognizer) {
        guard let mode = editMode else {
            return
        }

        switch mode {
        case .erase:
            guard let nodeView = sender.view as? NodeView else {
                return
            }
            nodeView.removeFrom(map: self.gameParameter.map)
            nodeView.node.remove()
            var offset = 0
            for (index, lineLayer) in lineLayerArr.enumerated() {
                if lineLayer.shipPath?.fromNode == nodeView.node
                    || lineLayer.shipPath?.toNode == nodeView.node {
                    lineLayerArr.remove(at: index - offset)
                    lineLayer.removeFromSuperlayer()
                    offset+=1
                }
            }
        case .item:
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
        case .pirate:
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
            nodeView.node.add(object: PirateIsland(in: nodeView.node))
            nodeView.update()
        default:
            return
        }

    }

    @objc func doubleTapOnNode(_ sender: UITapGestureRecognizer) {
        guard let node = sender.view as? NodeView, let port = node.node as? Port else {
            let alert = UIAlert(errorMsg: "Double click on port to assign ownership.", msg: nil)
            alert.present(in: self)
            return
        }

        if teamMenu.isHidden {
            UIView.animate(withDuration: 0, animations: {
                let point = node.convert(CGPoint(x: node.bounds.maxX, y: node.bounds.maxY), to: self.view)
                self.teamMenu.frame.origin = point
            })
            teamMenu.isHidden = false
        } else {
            teamMenu.isHidden = true
        }

        menuDest?.set(node: port, for: sender)
    }

    @objc func longPressOnNode(_ sender: UILongPressGestureRecognizer) {
        guard let node = sender.view as? NodeView else {
            return
        }

        if teamMenu.isHidden {
            UIView.animate(withDuration: 0, animations: {
                let point = node.convert(CGPoint(x: node.bounds.maxX, y: node.bounds.maxY), to: self.view)
                self.teamMenu.frame.origin = point
            })
            teamMenu.isHidden = false
        }

        menuDest?.set(node: node.node, for: sender)
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

            let path = Path(from: fromNode.node, to: toNode.node)
            let pathReversed = Path(from: toNode.node, to: fromNode.node)
            if gameParameter.map.getAllPaths().contains(path) {
                lineLayer.removeFromSuperlayer()
                return
            }
            lineLayer.set(path: path)
            gameParameter.map.add(path: path)
            gameParameter.map.add(path: pathReversed)
            lineLayer.path = bazier.cgPath
            lineLayerArr.append(lineLayer)
            let lineLayerR = PathView(path: pathReversed)
            lineLayerR.path = bazier.reversing().cgPath
            lineLayerArr.append(lineLayerR)
        default:
            return
        }
    }

    private func store(with name: String, replace: Bool = false) {
        var bounds = Rect(originX: 0, originY: 0,
                          height: Double(self.view.bounds.size.height),
                          width: Double(self.view.bounds.size.width))
        if let size = self.mapBackground.image?.size {
            bounds = Rect(originX: 0, originY: 0, height: Double(size.height), width: Double(size.width))
        }
        self.gameParameter.map.changeBackground("\(name)background", with: bounds)
        guard let background = self.mapBackground.image, let preview = self.scrollView.screenShot else {
            let alert = UIAlert(errorMsg: "Cannot save without background and preview image.", msg: "", confirm: { _ in
                self.store(with: name)
            })
            alert.present(in: self)
            return
        }

        do {
            let result = try storage.save(self.gameParameter, background,
                                          preview: preview, with: name, replace: replace)
            if result == false {
                let alert = UIAlert(errorMsg: "Save failed.", msg: "")
                alert.present(in: self)
            }
        } catch StorageError.fileExisted {
            let alert = UIAlert(errorMsg: "File Existed. Are you sure to replace?", msg: "", confirm: { _ in
                self.store(with: name, replace: true)
            })
            alert.present(in: self)
        } catch {
            let error = error as? StorageError
            let alert = UIAlert(errorMsg: error?.getMessage() ?? "Unknown Error.", msg: nil)
            alert.present(in: self)
        }
    }

    private func initBackground() {
        guard let image = storage.readImage(gameParameter.map.map) ?? UIImage(named: gameParameter.map.map) else {
                return
        }
        mapBackground.image = image
        layoutBackground()
    }

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
        editingAreaWrapper.subviews.forEach {
            $0.frame = mapBackground.frame
        }

        scrollView.contentSize = size
        scrollView.minimumZoomScale = max(view.frame.height/size.height, view.frame.width/size.width)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        mapBackground.image = image
    }

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

    private func initNodeGestures() -> [UIGestureRecognizer] {
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

    private func fillWith(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
