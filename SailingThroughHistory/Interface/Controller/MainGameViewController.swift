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
    @IBOutlet private weak var portOwnerLabel: UILabel!
    @IBOutlet private weak var portSetTaxButton: UIButtonRounded!
    @IBOutlet private weak var portItemsTableView: UITableView! {
        didSet {
            portItemsTableView.dataSource = portItemsDataSource
            portItemsTableView.delegate = portItemsDataSource
            portItemsTableView.reloadData()
        }
    }
    @IBOutlet private weak var portTaxLabel: UILabel!
    @IBOutlet private weak var portQuantityLabel: UILabel!
    @IBOutlet private weak var portQuantityAddButton: UIButton!
    @IBOutlet private weak var portQuantityMinusButton: UIButton!

    @IBOutlet private weak var availableUpgradesTableView: UITableView! {
        didSet {
            availableUpgradesTableView.dataSource = availableUpgradesDataSource
            availableUpgradesTableView.reloadData()
        }
    }
    @IBOutlet private weak var playerInfoWrapper: UIView!
    @IBOutlet private weak var playerMoneyLabel: UILabel!
    @IBOutlet private weak var playerShipCapacityLabel: UILabel!
    @IBOutlet private weak var playerCargoWeightLabel: UILabel!
    @IBOutlet private weak var playerItemsTable: UITableView!
    @IBOutlet private weak var togglePlayerInfoButton: UIButtonRounded!

    @IBOutlet private weak var toggleTeamScoresButton: UIButtonRounded!
    @IBOutlet private weak var teamScoresWrapper: UIBlurredBackgroundView!
    @IBOutlet private weak var teamScoreTableView: UITableView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var toggleActionPanelButton: UIButtonRounded!
    @IBOutlet private weak var diceResultLabel: UILabel!
    @IBOutlet private weak var actionPanelView: UIView!
    @IBOutlet private weak var countdownLabel: CountdownLabelView!
    @IBOutlet private weak var rollDiceButton: UIButtonRounded! {
        didSet {
            rollDiceButton.set(color: .red)
        }
    }

    @IBOutlet private weak var messagesTableView: UITableView!
    @IBOutlet private weak var messagesView: UIBlurredBackgroundView!
    @IBOutlet private weak var toggleMessagesButton: UIButtonRounded!

    @IBOutlet private weak var eventTableView: UITableView! {
        didSet {
            eventTableView.dataSource = eventsController
        }
    }
    @IBOutlet private weak var gameMasterPanel: UIBlurredBackgroundView!

    @IBOutlet weak var acknoledgeButtonView: UIButtonRounded!
    @IBOutlet weak var alertMessageView: UILabel!
    @IBOutlet weak var alertPanel: UIBlurredBackgroundView!

    private var currentTurnOwner: GenericPlayer?

    private lazy var objectsController: ObjectsViewController =
        ObjectsViewController(view: gameArea, modelBounds: model.map.bounds, delegate: self)
    private lazy var togglablePanels: [UIButton: UIView] = [
        togglePlayerInfoButton: playerInfoWrapper,
        toggleTeamScoresButton: teamScoresWrapper,
        toggleMessagesButton: messagesView]
    private lazy var portItemsDataSource = PortItemTableController(delegate: self)
    private lazy var availableUpgradesDataSource = AvailableUpgradesDataSource(mainController: self,
                                                                               availableUpgrades: model.availableUpgrades)
    private lazy var teamScoresController = TeamScoreTableController(tableView: teamScoreTableView,
                                                                     scores: Dictionary())
    private lazy var messagesController = MessagesTableController(tableView: messagesTableView)
    private lazy var eventsController = EventTableController(tableView: eventTableView, events: [], mainController: self)
    private lazy var alertController = AlertWindowController(delegate: self, wrapperView: alertPanel, messageView: alertMessageView, buttonView: acknoledgeButtonView)
    private var playerItemsDataSources = [PlayerItemsTableDataSource]()

    private let storage = LocalStorage()
    private var selectedPort: Port?
    var turnSystem: GenericTurnSystem?
    var network: RoomConnection?
    var backgroundData: Data?
    private var alertQueue = [UIAlertController]()
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
        view.window?.rootViewController = self
        network?.changeRemovalCallback { [weak self] in
            self?.performSegue(withIdentifier: "gameToMain", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let mainMenuController = segue.destination as? MainMenuViewController {
            mainMenuController.message = "You have been removed from the game."
        }
    }

    private func updateForState(_ state: TurnSystem.State) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let turnSystem = self.turnSystem else {
                return
            }
            self.messagesController.set(messages: turnSystem.messages)
            self.statusLabel.text = ""
            self.alertController.hide()
            self.playerTurnEnd()
            self.currentTurnOwner = nil
            self.objectsController.updatePathWeather()
            self.teamScoresController.set(scores: self.model.getTeamMoney())
            switch state {
            case .waitPlayerInput(let player):
                self.alertController.show(withMessage: "\(player.name)'s turn has started.")
            case .playerInput(let player, let endTime):
                self.statusLabel.text = "\(player.name)'s Turn"
                self.currentTurnOwner = player
                self.playerTurnStart(player: player, endTime: endTime)
            case .ready:
                break
            case .waitForTurnFinish:
                self.statusLabel.text = "Waiting for other players to finish..."
            case .waitForStateUpdate:
                break
            case .invalid:
                break
            case .evaluateMoves:
                break
            case .finished(let winner):
                let alert = ControllerUtils.getGenericAlert(
                titled: "\(winner?.name ?? "No one") has won, Congratulations!",
                withMsg: "") { [weak self] in
                    self?.performSegue(withIdentifier: "gameToMain", sender: nil)
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func buy(upgrade: Upgrade) {
        guard let currentTurnOwner = currentTurnOwner else {
            return
        }

        var msg: String?
        var title: String? = "Error"
        do {
            let result = try turnSystem?.purchase(upgrade: upgrade, by: currentTurnOwner)
            msg = result?.message
            title = result?.title
        } catch PlayerActionError.invalidAction(let errorMsg) {
            msg = errorMsg
        } catch {
            msg = error.localizedDescription
        }

        if let msg = msg, let title = title {
            let alert = ControllerUtils.getGenericAlert(titled: title, withMsg: msg)
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction private func portQuantityChange(_ sender: UIButton) {
        var quantity = Int(portQuantityLabel.text ?? "0") ?? 0
        switch sender {
        case portQuantityAddButton:
            quantity += 1
        case portQuantityMinusButton:
            quantity -= 1
        default:
            break
        }
        portQuantityLabel.text = String(quantity)
    }

    @IBAction private func togglePanelVisibility(_ sender: UIButtonRounded) {
        togglablePanels[sender]?.isHidden.toggle()
    }

    @IBAction private func toggleActionPanelVisibility(_ sender: UIButtonRounded) {
        guard let currentTurnOwner = currentTurnOwner else {
            actionPanelView.isHidden = true
            gameMasterPanel.isHidden = true
            return
        }
        if currentTurnOwner.isGameMaster {
            gameMasterPanel.isHidden.toggle()
            actionPanelView.isHidden = true
        } else {
            actionPanelView.isHidden.toggle()
            gameMasterPanel.isHidden = true
        }
    }

    @IBAction private func hidePortInformationPressed(_ sender: Any) {
        portInformationView.isHidden = true
    }

    @IBAction private func setTaxButtonPressed(_ sender: UIButtonRounded) {
        guard let player = currentTurnOwner,
            let port = selectedPort else {
            return
        }
        let alert2 = UIAlertController(title: "Changing tax of \(port.name)",
            message: "Please enter the amount you wish to change the tax to.",
            preferredStyle: .alert)
        alert2.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let input = alert2.textFields?.first?.text,
                let newTax = Int(input) else {
                let alert = ControllerUtils.getGenericAlert(titled: "Error", withMsg: "Only numbers are allowed.")
                self?.present(alert, animated: true, completion: nil)
                return
            }
            var msg: String?
            do {
                try self?.turnSystem?.setTax(for: port.identifier, to: newTax, by: player)
            } catch PlayerActionError.invalidAction(let errorMsg) {
                msg = errorMsg
            } catch {
                msg = error.localizedDescription
            }
            if let msg = msg {
                let alert = ControllerUtils.getGenericAlert(titled: "Error", withMsg: msg)
                self?.present(alert, animated: true, completion: nil)
            }
        }
        alert2.addAction(okAction)

        // Create Cancel button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert2.addAction(cancelAction)
        present(alert2, animated: true, completion: nil)
    }

    @IBAction private func rollDiceButtonPressed(_ sender: UIButtonRounded) {
        let randomLength = 5
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
                        let alert = ControllerUtils.getGenericAlert(
                            titled: "Error", withMsg: error.localizedDescription)
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

    @IBAction func gmEndTurnPressed(_ sender: Any) {
        turnSystem?.endTurn()
    }

    private func initBackground() {
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
        playerMoneyLabel.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
        playerCargoWeightLabel.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
        playerShipCapacityLabel.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
        playerItemsDataSources.removeAll()
        let dataSource = PlayerItemsTableDataSource(player: player,
                                                    tableView: playerItemsTable)
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
                self?.playerMoneyLabel.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
            }

            player.subscribeToCargoWeight { [weak self] player, cargo in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                self?.playerCargoWeightLabel.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
            }

            player.subscribeToWeightCapcity { [weak self] player, capacity in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                self?.playerShipCapacityLabel.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
            }
        }
    }

    private func playerTurnStart(player: GenericPlayer, endTime: TimeInterval) {
        guard let turnSystem = turnSystem else {
            fatalError("Turn system is nil")
        }
        func animatePlayerTurnStart() {
            if player.isGameMaster {
                gameMasterPanel.isHidden = false
                eventsController.set(events: turnSystem.getPresetEvents())
            } else {
                gameMasterPanel.isHidden = true
                actionPanelView.isHidden = false
                objectsController.makeShipGlow(for: player)
                availableUpgradesDataSource.enabled = player.canBuyUpgrade()
                availableUpgradesTableView.reloadData()
                toggleActionPanelButton.isHidden = false
                rollDiceButton.isEnabled = true
                rollDiceButton.set(color: .red)
            }
            countdownLabel.set(isHidden: false)
            countdownLabel.setCountDownTime(seconds: endTime - Date().timeIntervalSince1970)
            countdownLabel.start()
        }

        animatePlayerTurnStart()
        if player.isGameMaster {
            return
        }
        updatePlayerInformation(for: player)
    }

    private func playerTurnEnd() {
        actionPanelView.isHidden = true
        toggleActionPanelButton.isHidden = true
        countdownLabel.set(isHidden: true)
        portInformationView.isHidden = true
        availableUpgradesDataSource.enabled = false
        availableUpgradesTableView.reloadData()
        objectsController.resetChoosableNodes()
    }

    private func getTradeQuantity() -> Int {
        return Int(portQuantityLabel.text ?? "0") ?? 0
    }
}

extension MainGameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameAndBackgroundWrapper
    }
}

extension MainGameViewController {
    func toggle(event: PresetEvent, enabled: Bool) {
        guard let currentTurnOwner = currentTurnOwner else {
            return
        }
        var msg: String?
        do {
            try turnSystem?.toggle(eventId: event.identifier, enabled: enabled, by: currentTurnOwner)
        } catch PlayerActionError.invalidAction(let errorMsg) {
            msg = errorMsg
        } catch {
            msg = error.localizedDescription
        }
        let alert = ControllerUtils.getGenericAlert(titled: msg == nil ? "Success" : "Error",
                                                    withMsg: msg ?? "Successfully toggled")
        present(alert, animated: true, completion: nil)
    }
}

extension MainGameViewController: PortItemTableControllerDelegate {
    func portItemButtonPressed(action: PortItemButtonAction) {
        let quantity = getTradeQuantity()
        guard let currentTurnOwner = currentTurnOwner, quantity > 0 else {
            return
        }

        var errorMsg: String?
        do {
            switch action {
            case .playerBuy(let itemType):
                try turnSystem?.buy(itemType: itemType, quantity: quantity, by: currentTurnOwner)
            case .playerSell(let itemType):
                try turnSystem?.sell(itemType: itemType, quantity: quantity, by: currentTurnOwner)
            }
        } catch PlayerActionError.invalidAction(let msg) {
            errorMsg = msg
        } catch {
            if let error = error as? TradeItemError {
                errorMsg = error.getMessage()
            } else {
                errorMsg = error.localizedDescription
            }
        }

        if let errorMsg = errorMsg {
            let alert = ControllerUtils.getGenericAlert(titled: "Error", withMsg: errorMsg)
            self.present(alert, animated: true, completion: nil)
        }
        playerItemsTable.reloadData()
    }
}

extension MainGameViewController: AlertWindowDelegate {
    func acknoledgePressed() {
        turnSystem?.acknoledgeTurnStart()
    }
}

extension MainGameViewController: ObjectsViewControllerDelegate {
    func showInformation(of port: Port) {
        selectedPort = port
        portInformationView.isHidden = false
        portTaxLabel.text = "\(InterfaceConstants.taxPrefix)\(port.taxAmount.value)"
        portNameLabel.text = port.name
        portOwnerLabel.text = port.owner?.name ?? InterfaceConstants.unownedPortOwner
        portItemsDataSource.didSelect(port: port, playerCanInteract:
            currentTurnOwner?.canTradeAt(port: port) ?? false)
        portSetTaxButton.isHidden = currentTurnOwner == nil
            || port.owner != currentTurnOwner?.team

        portItemsTableView.reloadData()
    }
}
