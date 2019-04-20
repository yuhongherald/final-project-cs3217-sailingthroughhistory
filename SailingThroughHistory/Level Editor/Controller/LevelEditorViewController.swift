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
    @IBOutlet weak var teamMenu: UITableView! {
        didSet {
            teamMenu.dataSource = teamMenuDataSource
            teamMenu.delegate = teamMenuDataSource
            teamMenu.reloadData()
        }
    }
    @IBOutlet weak var editingAreaWrapper: UIView!
    @IBOutlet weak var mapBackground: UIImageView!
    @IBOutlet weak var panelToggle: UIButton!
    private var panelDest: EditPanelViewController?
    private lazy var teamMenuDataSource = TeamMenuDataSource(data: gameParameter.teams, delegate: self)

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
    var lineLayerArr = [PathView]()
    var lineLayer = PathView()
    private var startingNode: NodeView?
    private var destination: NodeView?

    let storage = LocalStorage()

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
        hideTeamMenu()
        guard let mode = editMode, editPanel.isHidden else {
            return
        }

        let location = sender.location(in: self.mapBackground)

        switch mode {
        case .erase:
            removePath(at: location)
        case .weather:
            addWeather(at: location)
        case .sea, .port:
            addNode(at: location)
        default:
            return
        }
    }

    @objc func singleTapOnNode(_ sender: UITapGestureRecognizer) {
        hideTeamMenu()
        guard let mode = editMode else {
            return
        }

        switch mode {
        case .erase:
            guard let nodeView = sender.view as? NodeView else {
                return
            }
            removeNode(nodeView)
        case .item:
            guard let portView = sender.view as? NodeView,
                let port = portView.node as? Port else {
                let alert = UIAlert(errorMsg: "Please select a port!", msg: nil)
                alert.present(in: self)
                return
            }

            presentItemEditor(for: port)
        case .pirate:
            guard let nodeView = sender.view as? NodeView else {
                let alert = UIAlert(errorMsg: "Please select a node!", msg: nil)
                alert.present(in: self)
                return
            }
            addPirate(to: nodeView)
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

        teamMenuDataSource.tableView = teamMenu

        if teamMenu.isHidden {
            UIView.animate(withDuration: 0, animations: {
                let point = node.convert(CGPoint(x: node.bounds.maxX, y: node.bounds.maxY), to: self.view)
                self.teamMenu.frame.origin = point
            })
            teamMenu.isHidden = false
        } else {
            teamMenu.isHidden = true
        }

        teamMenuDataSource.set(node: port, for: sender)
    }

    @objc func longPressOnNode(_ sender: UILongPressGestureRecognizer) {
        guard let node = sender.view as? NodeView else {
            return
        }

        teamMenuDataSource.tableView = teamMenu

        if teamMenu.isHidden {
            UIView.animate(withDuration: 0, animations: {
                let point = node.convert(CGPoint(x: node.bounds.maxX, y: node.bounds.maxY), to: self.view)
                self.teamMenu.frame.origin = point
            })
            teamMenu.isHidden = false
        }

        teamMenuDataSource.set(node: node.node, for: sender)
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
            destination?.addGlow(colored: .white)
        } else {
            destination?.removeGlow()
            destination = nil
        }
        let bazier = UIBezierPath()
        bazier.move(to: fromNode.center)

        switch sender.state {
        case .began:
            lineLayer = PathView()
            startingNode?.addGlow(colored: .white)
            editingAreaWrapper.layer.addSublayer(lineLayer)
        case .changed:
            bazier.addLine(to: endPoint)
            lineLayer.path = bazier.cgPath
        case .ended:
            startingNode?.removeGlow()
            destination?.removeGlow()
            destination = nil

            guard let toNode = endView else {
                lineLayer.removeFromSuperlayer()
                return
            }

            bazier.addLine(to: toNode.center)
            addPath(from: fromNode, to: toNode)
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
            let alert = UIAlert(errorMsg: "Store Failed.", msg: error?.getMessage() ?? "Unknown Error.")
            alert.present(in: self)
        }
    }

    private func removeNode(_ nodeView: NodeView) {
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
    }

    private func removePath(at location: CGPoint) {
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

    private func addWeather(at location: CGPoint) {
        self.lineLayerArr.forEach { path in
            if self.isPoint(point: location, withinDistance: 20, ofPath: path.path) {
                path.add(Weather())
            }
        }
    }

    private func addNode(at location: CGPoint) {
        let alert = UIAlert(title: "Input name: ", confirm: { ownerName in
            guard let nodeView = self.editMode?.getNodeView(name: ownerName, at: location) else {
                return
            }
            nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.map, with: self.initNodeGestures())
        }, textPlaceHolder: "Input name here.")
        alert.present(in: self)
    }

    private func addPath(from fromNode: NodeView, to toNode: NodeView) {
        let bazier = UIBezierPath()
        bazier.move(to: fromNode.center)
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
    }

    private func addPirate(to nodeView: NodeView) {
        if nodeView.node is Port {
            let alert = UIAlert(errorMsg: "You cannot add pirate to a port!", msg: nil)
            alert.present(in: self)
            return
        }
        nodeView.node.add(object: PirateIsland(in: nodeView.node))
        nodeView.update()
    }

    private func presentItemEditor(for port: Port) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "itemEditTable")
            as? ItemCollectionViewController else {
                fatalError("Controller itemEditTable cannot be casted into ItemCollectionViewController")
        }

        _ = controller.view
        controller.initWith(port: port)

        self.addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
}
