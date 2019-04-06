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

    private lazy var objectsController: ObjectsViewController =
        ObjectsViewController(view: gameArea, mainController: self)
    private lazy var togglablePanels: [UIButton: UIView] = [
        toggleActionPanelButton: actionPanelView,
        togglePlayerOneInfoButton: playerOneInformationView]
    private lazy var portItemsDataSource = PortItemTableDataSource(mainController: self)
    private var playerItemsDataSources = [PlayerItemsTableDataSource]()
    private let storage = LocalStorage()
    var turnSystem: GenericTurnSystem?
    var backgroundData: Data?
    private var model: GenericGameState {
        guard let turnSystem = turnSystem else {
            fatalError("Turn system is nil")
        }
        return turnSystem.gameState
    }

    var interfaceBounds: Rect {
        return model.map.bounds
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.playerTurnEnd()
            self.currentTurnOwner = nil
            switch state {
            case .waitPlayerInput(let player):
                let alert = ControllerUtils.getGenericAlert(titled: "\(player.name)'s turn has started.",
                withMsg: "") { [weak self] in
                    self?.turnSystem?.acknoledgeTurnStart()
                }
                self.present(alert, animated: true, completion: nil)
            case .playerInput(let player, let endTime):
                self.currentTurnOwner = player
                self.playerTurnStart(player: player, endTime: endTime)
            case .ready:
                break
            case .waitForTurnFinish:
                break
            case .waitForStateUpdate:
                break
            case .invalid:
                break
            case .evaluateMoves(_):
                break
            }
        }
    }

    func showInformation(ofPort port: Port) {
        portInformationView.isHidden = false
        portNameLabel.text = port.name
        portItemsDataSource.didSelect(port: port, playerCanInteract:
            currentTurnOwner?.canTradeAt(port: port) ?? false)
        portItemsTableView.reloadData()
    }

    func portItemButtonPressed(action: PortItemButtonAction) {
        guard let currentTurnOwner = currentTurnOwner else {
            return
        }
        var errorMsg: String?
        do {
            switch action {
            case .playerBuy(let itemType):
                try turnSystem?.buy(itemType: itemType, quantity: 1, by: currentTurnOwner)
            case .playerSell(let itemType):
                try turnSystem?.sell(itemType: itemType, quantity: 1, by: currentTurnOwner)
            }
        } catch PlayerActionError.invalidAction(let msg) {
            errorMsg = msg
        } catch {
            errorMsg = error.localizedDescription
        }

        if let errorMsg = errorMsg {
            let alert = ControllerUtils.getGenericAlert(titled: "Error", withMsg: errorMsg)
            present(alert, animated: true, completion: nil)
        }
        playerOneItemsView.reloadData()
    }

    @IBAction private func togglePanelVisibility(_ sender: UIButtonRounded) {
        togglablePanels[sender]?.isHidden.toggle()
    }

    @IBAction private func hidePortInformationPressed(_ sender: Any) {
        portInformationView.isHidden = true
    }

    @IBAction private func rollDiceButtonPressed(_ sender: UIButtonRounded) {
        let randomLength = 20
        sender.isEnabled = false
        sender.set(color: .lightGray)
        for interval in 0...randomLength {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01 * pow(Double(interval), 2)) { [weak self] in
                if interval == randomLength {
                    guard let currentTurnOwner = self?.currentTurnOwner, let turnSystem = self?.turnSystem else {
                        return
                    }
                    do {
                        let (result, nodes) = try turnSystem.roll(for: currentTurnOwner)
                        self?.diceResultLabel.text = String(Int(result))
                        self?.objectsController.make(choosableNodes: nodes)
                    } catch {
                        let alert = ControllerUtils.getGenericAlert(titled: "Error", withMsg: error.localizedDescription)
                        self?.rollDiceButton.isEnabled = true
                        self?.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                self?.diceResultLabel.text = String(Int.random(in: 1...6))
            }
        }
    }

    @IBAction private func onTapGameArea(_ sender: UITapGestureRecognizer) {
        let view = gameArea.hitTest(sender.location(in: gameArea), with: nil)
        guard let nodeView = view as? NodeView else {
            return
        }
        let nodeId = objectsController.onTap(nodeView: nodeView)
        guard let currentTurnOwner = currentTurnOwner else {
            return
        }
        if !currentTurnOwner.hasRolled {
            return
        }
        let name = nodeView.node.name
        let alert = ControllerUtils.getConfirmationAlert(title: "Travel Confirmation",
                                                         desc: "Are you sure you would like to travel to \(name)?",
            okAction: { [weak self] in
                do {
                    try self?.turnSystem?.selectForMovement(nodeId: nodeId, by: currentTurnOwner)
                } catch {
                    let alert = ControllerUtils.getGenericAlert(titled: "Error", withMsg: "Please try again.")
                    self?.present(alert, animated: true, completion: nil)
                }
                self?.turnSystem?.endTurn()
            }, cancelAction: nil)

        present(alert, animated: true, completion: nil)
    }

    private func initBackground() {
        /// TODO: Change map
        guard let backgroundData = backgroundData,
            let gameAndBackgroundWrapper = self.gameAndBackgroundWrapper else {
            return
        }

        guard let image = UIImage(data: backgroundData) else {
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
        let dataSource = PlayerItemsTableDataSource(player: player,
                                                    tableView: playerOneItemsView)
        playerItemsDataSources.append(dataSource)
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

    private func playerTurnStart(player: GenericPlayer, endTime: TimeInterval) {

        func animatePlayerTurnStart() {
            actionPanelView.isHidden = false
            toggleActionPanelButton.isHidden = false
            rollDiceButton.isEnabled = true
            rollDiceButton.set(color: .red)
            countdownLabel.isHidden = false
            countdownLabel.animationType = CountdownEffect.Burn
            countdownLabel.setCountDownTime(minutes: endTime - Date().timeIntervalSince1970)
            countdownLabel.start()
        }

        animatePlayerTurnStart()
        updatePlayerInformation(for: player)
    }

    private func playerTurnEnd() {
        actionPanelView.isHidden = true
        toggleActionPanelButton.isHidden = true
        countdownLabel.isHidden = true
        portInformationView.isHidden = true
        countdownLabel.isHidden = true
        objectsController.resetChoosableNodes()
    }
}

extension MainGameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameAndBackgroundWrapper
    }
}
