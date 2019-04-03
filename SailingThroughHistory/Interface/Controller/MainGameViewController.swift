//
//  ViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit
import CountdownLabel

class MainGameViewController: UIViewController {
    @IBOutlet private weak var gameAndBackgroundWrapper: UIView!
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 3
        }
    }
    @IBOutlet private weak var contextView: UIView!
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
    @IBOutlet private weak var playerOneGoldView: UILabel!
    @IBOutlet private weak var playerOneCapacityView: UILabel!
    @IBOutlet private weak var playerOneCargoView: UILabel!
    @IBOutlet weak var playerOneItemsView: UITableView!
    @IBOutlet private weak var togglePlayerOneInfoButton: UIButtonRounded!

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
    private lazy var pathsController: PathsViewController = PathsViewController(view: gameArea, mainController: self)
    private lazy var objectsController: ObjectsViewController =
        ObjectsViewController(view: gameArea, mainController: self)
    private lazy var togglablePanels: [UIButton: UIView] = [
        toggleActionPanelButton: actionPanelView,
        togglePlayerOneInfoButton: playerOneInformationView,
        togglePlayerTwoInfoButton: playerTwoInformationView]
    private lazy var portItemsDataSource = PortItemTableDataSource(mainController: self)
    private var playerItemsDataSources = [PlayerItemsTableDataSource]()
    var turnSystem: GenericTurnSystem?
    private var model: GenericGameState {
        guard let turnSystem = turnSystem else {
            fatalError("Turn system is nil")
        }
        return turnSystem.gameState
    }

    var interfaceBounds: CGRect {
        /// TODO: Fix
        return CGRect(fromRect: model.map.bounds)
        //return CGRect(fromRect: interface.bounds)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reInitScrollView()
        initBackground()
        objectsController.subscribeToNodes(in: model.map)
        objectsController.subscribeToPaths(in: model.map)
        objectsController.subscribeToObjects(in: model.map)
        turnSystem?.subscribeToState(with: updateForState)
        subscribePlayerInformation(for: model.getPlayers())
    }

    override func viewDidAppear(_ animated: Bool) {
        turnSystem?.startGame()
    }

    private func updateForState(_ state: TurnSystem.State) {
        playerTurnEnd()
        currentTurnOwner = nil
        switch state {
        case .playerInput(let player):
            currentTurnOwner = player
            playerTurnStart(player: player)
            break
        case .ready:
            break
        case .waitForTurnFinish:
            break
        case .waitForStateUpdate:
            break
        case .invalid:
            
            break
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
        /// TODO: Change map
        guard let image = UIImage(named: "worldmap1815.png"),
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

    private func updatePlayerInformation(for player: GenericPlayer) {
        let gold = player.money.value
        let cargo = player.currentCargoWeight
        let capacity = player.weightCapacity
        playerOneGoldView.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
        playerOneCargoView.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
        playerOneCapacityView.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
        playerItemsDataSources.removeAll()
        playerItemsDataSources.append(PlayerItemsTableDataSource(player: player,
                                                                 tableView: playerOneItemsView))
    }

    private func subscribePlayerInformation(for players: [GenericPlayer]) {
        for player in players {
            player.subscribeToMoney { [weak self] player, gold in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                self?.playerOneGoldView.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
            }

            player.subscribeToCargoWeight { [weak self] player, cargo in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                self?.playerOneCargoView.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
            }

            player.subscribeToWeightCapcity { [weak self] player, capacity in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                self?.playerOneCapacityView.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
            }
        }
    }

    private func remove(object: ReadOnlyGameObject, withDuration duration: TimeInterval, callback:
        @escaping () -> Void) {
        pathsController.removeAllPathsAssociated(with: object, withDuration: duration)
        objectsController.remove(object: object, withDuration: duration, callback: callback)
    }

    private func pauseAndShowAlert(titled title: String, withMsg msg: String, callback: @escaping () -> Void) {
        let alert = ControllerUtils.getGenericAlert(titled: title, withMsg: msg, action: callback)

        present(alert, animated: true, completion: nil)
    }

    private func playerTurnStart(player: GenericPlayer) {

        func animatePlayerTurnStart() {
            actionPanelView.isHidden = false
            toggleActionPanelButton.isHidden = false
            /*if let timeLimit = timeLimit {
                countdownLabel.isHidden = false
                countdownLabel.animationType = CountdownEffect.Burn
                countdownLabel.setCountDownTime(
                    minutes: timeLimit)
                countdownLabel.then(targetTime: 1) { [weak self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        timeOutCallback?()
                        self?.playerTurnEnd()
                    }
                }
                countdownLabel.start()
            }*/
        }

        let alert = ControllerUtils.getGenericAlert(titled: "\(player.name)'s turn has started.",
            withMsg: "") { [weak self] in
                animatePlayerTurnStart()
                self?.updatePlayerInformation(for: player)
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
