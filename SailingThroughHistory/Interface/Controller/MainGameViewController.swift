//
//  ViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit
import RxSwift
import CountdownLabel

class MainGameViewController: UIViewController {
    @IBOutlet private weak var gameAndBackgroundWrapper: UIView!
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 3
        }
    }
    @IBOutlet private weak var environmentView: UIView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var gameArea: UIView!

    @IBOutlet private weak var portInformationView: UIView!
    @IBOutlet private weak var portNameLabel: UILabel!
    @IBOutlet private weak var portItemsTableView: UITableView! {
        didSet {
            portItemsTableView.dataSource = portItemsDataSource
            portItemsTableView.delegate = portItemsDataSource
            portItemsTableView.reloadData()
        }
    }
    
    @IBOutlet private weak var playerOneInformationView: UIView!
    @IBOutlet private weak var playerTwoInformationView: UIView!
    @IBOutlet private weak var playerOneGoldView: UILabel!
    @IBOutlet private weak var playerTwoGoldView: UILabel!
    @IBOutlet private weak var playerOneCapacityView: UILabel!
    @IBOutlet private weak var playerTwoCapacityView: UILabel!
    @IBOutlet private weak var playerOneCargoView: UILabel!
    @IBOutlet private weak var playerTwoCargoView: UILabel!
    @IBOutlet weak var playerOneItemsView: UITableView!
    @IBOutlet weak var playerTwoItemsView: UITableView!
    @IBOutlet private weak var togglePlayerOneInfoButton: UIButtonRounded!
    @IBOutlet private weak var togglePlayerTwoInfoButton: UIButtonRounded!

    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var toggleActionPanelButton: UIButtonRounded!
    @IBOutlet private weak var diceResultLabel: UILabel!
    @IBOutlet private weak var actionPanelView: UIView!
    @IBOutlet private weak var countdownLabel: CountdownLabel!
    @IBOutlet private weak var rollDiceButton: UIButtonRounded! {
        didSet {
            rollDiceButton.set(color: .red)
        }
    }

    private var currentTurnOwner: GenericPlayer?

    /// TODO: Reference to Game Engine
    private lazy var interface: Interface = Interface(players: [], bounds: backgroundImageView.frame)
    private lazy var pathsController: PathsViewController = PathsViewController(view: gameArea, mainController: self)
    private lazy var objectsController: ObjectsViewController =
        ObjectsViewController(view: gameArea, mainController: self)
    private lazy var togglablePanels: [UIButton: UIView] = [
        toggleActionPanelButton: actionPanelView,
        togglePlayerOneInfoButton: playerOneInformationView,
        togglePlayerTwoInfoButton: playerTwoInformationView]
    private lazy var portItemsDataSource = PortItemTableDataSource(mainController: self)
    private var playerItemsDataSources = [PlayerItemsTableDataSource]()

    var interfaceBounds: CGRect {
        return interface.bounds
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reInitScrollView()
        initBackground()
        //Uncomment to test interface
        let object = GameObject(image: "ship.png", frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        self.interface.add(object: object)
        let nodeDummy = Node(name: "testnode", image: "sea-node.png",
                             frame: CGRect(x: 500, y: 500, width: 50, height: 50))
        let object2 = Port(player: Player(name: "test", node: nodeDummy), pos: CGPoint(x: 500, y: 500))
        object2.itemParametersSold = [ItemParameter(itemType: ItemType.opium, displayName: "Opium", weight: 1, isConsumable: true)]
        let path = Path(from: object, to: object2)
        self.interface.add(object: object2)
        self.interface.broadcastInterfaceChanges(withDuration: 3)
        self.interface.showTravelChoices([object2]) { [weak self] (_: GameObject)  in
            let alert = ControllerUtils.getGenericAlert(titled: "Title", withMsg: "Msg")
            self?.present(alert, animated: true, completion: nil)
            }
        //TODO
        self.interface.playerTurnStart(player: Player(name: "test", node: object2), timeLimit: 120) { [weak self] in
            let alert = ControllerUtils.getGenericAlert(titled: "Time up!", withMsg: "Msg")
            self?.present(alert, animated: true, completion: nil)
        }

        subscribeToInterface()

        self.interface.add(path: path)
        self.interface.broadcastInterfaceChanges(withDuration: 5)
         //Uncomment to test interface
        DispatchQueue.global(qos: .background).async { [weak self] in
            while true {
                object.frame = object.frame.applying(CGAffineTransform(translationX: 50, y: 50))
                self?.interface.updatePosition(of: object)
                self?.interface.broadcastInterfaceChanges(withDuration: 1)
            }
        }
    }

    func getFrame(for object: GameObject) -> CGRect? {
        return objectsController.getFrame(for: object)
    }

    func showInformation(ofPort port: Port) {
        portInformationView.isHidden = false
        portNameLabel.text = port.name
        portItemsDataSource.didSelect(port: port, playerCanInteract:
            currentTurnOwner?.node === port)
        portItemsTableView.reloadData()
    }

    func portItemButtonPressed(action: PortItemButtonAction) {

    }

    @IBAction func togglePanelVisibility(_ sender: UIButtonRounded) {
        togglablePanels[sender]?.isHidden.toggle()
    }

    @IBAction func hidePortInformationPressed(_ sender: Any) {
        portInformationView.isHidden = true
    }

    @IBAction func rollDiceButtonPressed(_ sender: UIButtonRounded) {
        sender.isEnabled = false
        sender.set(color: .lightGray)
        for interval in 0...20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01 * pow(Double(interval), 2)) { [weak self] in
                self?.diceResultLabel.text = String(Int.random(in: 1...6))
            }
        }
        /// TODO: Roll dice logic
    }

    @IBAction func onTapGameArea(_ sender: UITapGestureRecognizer) {
        let view = gameArea.hitTest(sender.location(in: gameArea), with: nil)

        if let objectView = view as? UIGameObjectImageView {
            objectsController.onTap(objectView: objectView)
        }
    }

    private func initBackground() {
        guard let image = UIImage(named: interface.background),
            let gameAndBackgroundWrapper = self.gameAndBackgroundWrapper else {
            return
        }

        backgroundImageView.contentMode = .topLeft
        backgroundImageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        gameAndBackgroundWrapper.frame = backgroundImageView.frame
        gameAndBackgroundWrapper.subviews.forEach {
            $0.frame = gameAndBackgroundWrapper.frame
        }

        scrollView.contentSize = image.size
        scrollView.minimumZoomScale = max(view.frame.height/image.size.height, view.frame.width/image.size.width)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        backgroundImageView.image = image
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
        gameAndBackgroundWrapper.removeFromSuperview()
        scrollView.addSubview(gameAndBackgroundWrapper)
    }

    private func subscribeToInterface() {
        if let currentTurnOwner = interface.currentTurnOwner {
            playerTurnStart(player: currentTurnOwner, timeLimit: nil, timeOutCallback: { }, callback: { })
        }

        syncObjectsAndPaths(with: interface)
        subscribePlayerInformation(players: interface.players)

        interface.subscribe { [weak self] in
            guard let events = $0.element else {
                return
            }

            self?.handle(events: events)
        }
    }

    private func syncObjectsAndPaths(with interface: Interface) {
        interface.objectFrames.forEach {
            objectsController.add(object: $0.key, at: $0.value,
                                  withDuration: InterfaceConstants.defaultAnimationDuration,
                                  callback: {})
        }

        interface.paths.allPaths.forEach { [weak self] in
            self?.pathsController.add(path: $0,
                                      withDuration: InterfaceConstants.defaultAnimationDuration,
                                      callback: {})
        }
    }

    private func subscribePlayerInformation(players: [GenericPlayer]) {
        /// TODO: Less hackish
        if players.indices.contains(0) {
            players[0].money.subscribe { [weak self] in
                guard let gold = $0.element else {
                    self?.playerOneGoldView.text = "\(InterfaceConstants.moneyPrefix)Error"
                    return
                }

                self?.playerOneGoldView.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
            }

            players[0].subscribeToCargoWeight { [weak self] in
                guard let cargo = $0.element else {
                    return
                }

                self?.playerOneCargoView.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
            }

            players[0].subscribeToWeightCapcity { [weak self] in
                guard let capacity = $0.element else {
                    return
                }

                self?.playerOneCargoView.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
            }

            playerItemsDataSources.append(PlayerItemsTableDataSource(player: players[0],
                                                                     tableView: playerOneItemsView))
        }

        if players.indices.contains(1) {
            players[1].money.subscribe { [weak self] in
                guard let gold = $0.element else {
                    self?.playerTwoGoldView.text = "\(InterfaceConstants.moneyPrefix)Error"
                    return
                }

                self?.playerTwoGoldView.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
            }

            players[1].subscribeToCargoWeight { [weak self] in
                guard let cargo = $0.element else {
                    return
                }

                self?.playerTwoCargoView.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
            }

            players[1].subscribeToWeightCapcity { [weak self] in
                guard let capacity = $0.element else {
                    return
                }

                self?.playerTwoCargoView.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
            }

            playerItemsDataSources.append(PlayerItemsTableDataSource(player: players[1],
                                                                     tableView: playerTwoItemsView))
        }
    }

    private func remove(object: GameObject, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        pathsController.removeAllPathsAssociated(with: object, withDuration: duration)
        objectsController.remove(object: object, withDuration: duration, callback: callback)
    }

    private func handle(events: InterfaceEvents) {
        let semaphore = DispatchSemaphore(value: 0)

        for index in events.events.indices {
            let event = events.events[index]
            DispatchQueue.main.async { [weak self] in
                self?.handle(event: event, withDuration: events.duration) { semaphore.signal() }
            }
        }

        for _ in events.events {
            semaphore.wait()
        }
    }

    private func handle(event: InterfaceEvent, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        switch event {
        case .move(let object, let dest):
            objectsController.move(object: object, to: dest, withDuration: duration, callback: callback)
        case .addPath(let path):
            pathsController.add(path: path, withDuration: duration, callback: callback)
        case .addObject(let object, let frame):
            objectsController.add(object: object, at: frame, withDuration: duration, callback: callback)
        case .changeMonth(let newMonth):
            changeMonth(to: newMonth, withDuration: duration, callback: callback)
        case .playerTurnStart(let player, let timeLimit, let timeOutCallback):
            playerTurnStart(player: player, timeLimit: timeLimit, timeOutCallback: timeOutCallback, callback: callback)
        case .pauseAndShowAlert(let title, let msg):
            pauseAndShowAlert(titled: title, withMsg: msg, callback: callback)
        case .removePath(let path):
            pathsController.remove(path: path, withDuration: duration, callback: callback)
        case .removeObject(let object):
            remove(object: object, withDuration: duration, callback: callback)
        case .showTravelChoices(let nodes, let selectCallback):
            objectsController.makeChoosable(nodes: nodes, withDuration: duration,
                                            tapCallback: selectCallback, callback: callback)
        default:
            print("Unsupported event not handled.")
        }
    }

    private func pauseAndShowAlert(titled title: String, withMsg msg: String, callback: @escaping () -> Void) {
        let alert = ControllerUtils.getGenericAlert(titled: title, withMsg: msg, action: callback)

        present(alert, animated: true, completion: nil)
    }

    private func playerTurnStart(player: GenericPlayer, timeLimit: TimeInterval?, timeOutCallback: @escaping () -> Void,
                                 callback: @escaping () -> Void) {

        func animatePlayerTurnStart() {
            actionPanelView.isHidden = false
            toggleActionPanelButton.isHidden = false
            if let timeLimit = timeLimit {
                countdownLabel.isHidden = false
                countdownLabel.animationType = CountdownEffect.Burn
                countdownLabel.setCountDownTime(
                    minutes: timeLimit)
                countdownLabel.then(targetTime: 1) { [weak self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        timeOutCallback()
                        self?.playerTurnEnd()
                    }
                }
                countdownLabel.start()
            }
        }

        let alert = ControllerUtils.getGenericAlert(titled: "\(player.name)'s turn has started.",
            withMsg: "") {
            animatePlayerTurnStart()
            callback()
        }

        present(alert, animated: true, completion: nil)
    }

    private func playerTurnEnd() {
        actionPanelView.isHidden = true
        toggleActionPanelButton.isHidden = true
        countdownLabel.isHidden = true
        portInformationView.isHidden = true
    }

    private func changeMonth(to newMonth: String, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        UIView.animate(withDuration: duration / 2, animations: { [unowned self] in
            self.monthLabel.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: duration / 2, animations: {
                    self.monthLabel.alpha = 1
                    self.monthLabel.text = newMonth
                }, completion: { _ in
                    callback() })
        })
    }
}

extension MainGameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameAndBackgroundWrapper
    }
}
