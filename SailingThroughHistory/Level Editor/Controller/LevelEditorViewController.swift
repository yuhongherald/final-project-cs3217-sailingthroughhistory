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
        showPanel()

        teamMenu.frame.size = CGSize(width: 200, height: 100)
        teamMenu.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnMap(_:)))
        editingAreaWrapper.addGestureRecognizer(tapGesture)
    }

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    /// Button action for toggle panel.
    @IBAction func editPressed(_ sender: Any) {
        if editPanel.isHidden {
            showPanel()
        } else {
            hidePanel()
        }
    }

    @IBAction func savePressed(_ sender: Any) {
        let alert = ControllerUtils.getTextfieldAlert(title: "Save Level with Name: ", desc: "",
                                                      textPlaceHolder: "Input level name here",
                                                      okAction: { name in
                                                          self.store(with: name)
                                                      }, cancelAction: nil)
        self.present(alert, animated: true, completion: nil)
    }

    /// Deal with tapping on map action:
    ///   Under erase mode: remove path
    ///   Under add weather mode: add weather
    ///   Under add node mode: add the corresponding node selected
    /// - Parameters:
    ///    - sender: tap gesture recognizer
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

    /// Deal with single tapping on node action:
    ///   Under erase mode: remove node
    ///   Under edit item mode: show item editor page
    ///   Under add pirate mode: add pirate to the selected sea
    /// - Parameters:
    ///    - sender: tap gesture recognizer
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
                let alert = ControllerUtils.getGenericAlert(titled: "Please select a port!", withMsg: "")
                self.present(alert, animated: true, completion: nil)
                return
            }

            presentItemEditor(for: port)
        case .pirate:
            guard let nodeView = sender.view as? NodeView else {
                let alert = ControllerUtils.getGenericAlert(titled: "Please select a node!", withMsg: "")
                self.present(alert, animated: true, completion: nil)
                return
            }
            addPirate(to: nodeView)
        default:
            return
        }

    }

    /// Deal with double tapping on node action:
    ///   Show team menu view and set port ownership to the selected team.
    /// - Parameters:
    ///    - sender: tap gesture recognizer
    @objc func doubleTapOnNode(_ sender: UITapGestureRecognizer) {
        guard let node = sender.view as? NodeView, let port = node.node as? Port else {
            let alert = ControllerUtils.getGenericAlert(titled: "Double click on port to assign ownership.",
                                                        withMsg: "")
            self.present(alert, animated: true, completion: nil)
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

    /// Deal with long pressing on node action:
    ///   Show team menu view and set the node to starting point of the selected team.
    /// - Parameters:
    ///    - sender: long press gesture recognizer
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

    /// Deal with long pressing on node action:
    ///   Show the path to be added.
    ///   Show glow of two ends of the path to be added.
    ///   Add path to map.
    /// - Parameters:
    ///    - sender: pan gesture recognizer
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

    /// Attempt to store the level data with the input name.
    /// - Parameters:
    ///   - name: level name
    ///   - replace: whether to replace the original level if a level with the same name already exists
    private func store(with name: String, replace: Bool = false) {
        var bounds = Rect(originX: 0, originY: 0,
                          height: Double(self.view.bounds.size.height),
                          width: Double(self.view.bounds.size.width))
        if let size = self.mapBackground.image?.size {
            bounds = Rect(originX: 0, originY: 0, height: Double(size.height), width: Double(size.width))
        }
        self.gameParameter.map.changeBackground("\(name)background", with: bounds)
        guard let background = self.mapBackground.image, let preview = self.scrollView.screenShot else {
            let alert = ControllerUtils.getConfirmationAlert(title: "Cannot save without background and preview image.",
                                                             desc: "",
                                                             okAction: {
                self.store(with: name)
            }, cancelAction: nil)
            self.present(alert, animated: true, completion: nil)
            return
        }

        do {
            let result = try storage.save(self.gameParameter, background,
                                          preview: preview, with: name, replace: replace)
            if result == false {
                let alert = ControllerUtils.getGenericAlert(titled: "Save failed.", withMsg: "")
                self.present(alert, animated: true, completion: nil)
            }
        } catch StorageError.fileExisted {
            let alert = ControllerUtils.getGenericAlert(titled: "File Existed. Are you sure to replace?", withMsg: "",
                                                        action: { self.store(with: name, replace: true)})
            self.present(alert, animated: true, completion: nil)
        } catch {
            let error = error as? StorageError
            let alert = ControllerUtils.getGenericAlert(titled: "Store Failed.",
                                                        withMsg: error?.getMessage() ?? "Unknown Error.")
            self.present(alert, animated: true, completion: nil)
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
        let alert = ControllerUtils.getTextfieldAlert(title: "Input name: ", desc: "",
                                                      textPlaceHolder: "Input name here.",
                                                      okAction: { ownerName in
        guard let nodeView = self.editMode?.getNodeView(name: ownerName, at: location) else {
            return
        }
        nodeView.addTo(self.editingAreaWrapper, map: self.gameParameter.map, with: self.initNodeGestures())
        }, cancelAction: nil)
        self.present(alert, animated: true, completion: nil)
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
            let alert = ControllerUtils.getGenericAlert(titled: "You cannot add pirate to a port!", withMsg: "")
            self.present(alert, animated: true, completion: nil)
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
