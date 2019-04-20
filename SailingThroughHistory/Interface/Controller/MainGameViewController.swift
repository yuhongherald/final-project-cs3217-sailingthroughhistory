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
    private lazy var availableUpgradesDataSource =
        AvailableUpgradesController(delegate: self,
                                    availableUpgrades: model.availableUpgrades)
    private lazy var teamScoresController = TeamScoreTableController(tableView: teamScoreTableView,
                                                                     scores: Dictionary())
    private lazy var messagesController = MessagesTableController(tableView: messagesTableView)
    private lazy var eventsController = EventTableController(tableView: eventTableView, events: [],
                                                             delegate: self)
    private lazy var alertController = AlertWindowController(delegate: self, wrapperView: alertPanel,
                                                             messageView: alertMessageView,
                                                             buttonView: acknoledgeButtonView)
    private var playerItemsDataSources = [PlayerItemsTableController]()

    private let storage = LocalStorage()
    private var selectedPort: Port?
    private var alertQueue = [UIAlertController]()
    private var model: GenericGameState {
        guard let turnSystem = turnSystem else {
            fatalError("Turn system is nil")
        }
        return turnSystem.gameState
    }

    var turnSystem: GenericTurnSystem?
    var network: RoomConnection?
    var backgroundData: Data?

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

    /// Update the interface for the given turn system state.
    ///
    /// - Parameter state: The current TurnSystem state.
    private func updateForState(_ state: TurnSystemNetwork.State) {
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
            self.gameMasterPanel.isHidden = true
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

    /// Change the desired quantity for port trade actions.
    ///
    /// - Parameter sender: The sender of the actions.
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

    /// Toggles the visibility of the panel that the sender is responsible for.
    ///
    /// - Parameter sender: The sender of this action.
    @IBAction private func togglePanelVisibility(_ sender: UIButtonRounded) {
        togglablePanels[sender]?.isHidden.toggle()
    }

    /// Toggles the visibility of the action panel, depending on who's turn it currently is. If it is a game master,
    /// then the game master panel will be shown. If it is a normal player, the normal player's interface will be shown.
    ///
    /// - Parameter sender: The sender of tihis action.
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

    /// Hides the port information panel.
    ///
    /// - Parameter sender: The sender of this action.
    @IBAction private func hidePortInformationPressed(_ sender: Any) {
        portInformationView.isHidden = true
    }

    /// Shows the set tax dialog for the user to change the tax of this port.
    ///
    /// - Parameter sender: The sender of this action.
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

    /// Roll dice and show the ports that the player can travel to.
    ///
    /// - Parameter sender: The sender of this action.
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

    /// Called when game area is tapped, if a port is tapped, the information for that port is shown. If the current
    /// player has rolled, then he will be shown a confirmation dialogue for moving to that node.
    ///
    /// - Parameter sender: The sender of this action
    @IBAction private func onTapGameArea(_ sender: UITapGestureRecognizer) {
        let view = gameArea.hitTest(sender.location(in: gameArea), with: nil)
        guard let nodeView = view as? NodeView else {
            return
        }
        let nodeId = objectsController.onTap(nodeView: nodeView)
        guard let currentTurnOwner = currentTurnOwner else {
            return
        }
        if !currentTurnOwner.hasRolled || !currentTurnOwner.roll().1.contains(nodeId) {
            return
        }
        let name = nodeView.node.name
        let alert = ControllerUtils.getConfirmationAlert(title: "Travel Confirmation",
                                                         desc: "Are you sure you would like to travel to \(name)?",
            okAction: { [weak self] in
                do {
                    try self?.turnSystem?.selectForMovement(nodeId: nodeId, by: currentTurnOwner)
                    self?.turnSystem?.endTurn()
                } catch {
                    let alert = ControllerUtils.getGenericAlert(titled: "Error",
                                                                withMsg: "Please try again with a glowing node.")
                    self?.present(alert, animated: true, completion: nil)
                }
            }, cancelAction: nil)

        present(alert, animated: true, completion: nil)
    }

    /// Called when the GM Panel's end turn button is pressed. Shows a confirmation alert for ending the turn.
    ///
    /// - Parameter sender: The sender of this action.
    @IBAction func gmEndTurnPressed(_ sender: Any) {
        let alert = ControllerUtils.getConfirmationAlert(title: "Confirmation",
                                                         desc: "Are you sure you would like to end your turn?",
            okAction: { [weak self] in
                self?.turnSystem?.endTurn()
            }, cancelAction: nil)

        present(alert, animated: true, completion: nil)
    }

    /// Initializes the background view for the game with the appropriate image.
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

    /// Reinitializes the scroll view to allow for size changes. The scroll view generated by the storyboard does not
    /// allow for size changes easily.
    private func reInitScrollView() {
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

    /// Updates the player information panel for the input player.
    ///
    /// - Parameter player: The current player.
    private func updatePlayerInformation(for player: GenericPlayer) {
        let gold = player.money.value
        let cargo = player.currentCargoWeight
        let capacity = player.weightCapacity
        playerMoneyLabel.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
        playerCargoWeightLabel.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
        playerShipCapacityLabel.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
        playerItemsDataSources.removeAll()
        let dataSource = PlayerItemsTableController(player: player,
                                                    tableView: playerItemsTable)
        playerItemsDataSources.append(dataSource)
    }

    /// Subscibe to player information changes for all players
    ///
    /// - Parameter players: The players in the game.
    private func subscribePlayerInformation(for players: [GenericPlayer]) {
        for player in players {
            player.subscribeToMoney { [weak self] player, gold in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                DispatchQueue.main.async {
                    self?.playerMoneyLabel.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
                }
            }

            player.subscribeToCargoWeight { [weak self] player, cargo in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                DispatchQueue.main.async {
                    self?.playerCargoWeightLabel.text = "\(InterfaceConstants.cargoPrefix)\(cargo)"
                }
            }

            player.subscribeToWeightCapcity { [weak self] player, capacity in
                guard let currentTurnOwner = self?.currentTurnOwner else {
                    return
                }
                if currentTurnOwner != player {
                    return
                }
                DispatchQueue.main.async {
                    self?.playerShipCapacityLabel.text = "\(InterfaceConstants.capacityPrefix)\(capacity)"
                }
            }
        }
    }

    /// Shows appropriate interface when the player turn starts.
    ///
    /// - Parameters:
    ///   - player: The player who's turn has started.
    ///   - endTime: The ending time limit of the turn.
    private func playerTurnStart(player: GenericPlayer, endTime: TimeInterval) {
        guard let turnSystem = turnSystem else {
            fatalError("Turn system is nil")
        }
        func animatePlayerTurnStart() {
            if player.isGameMaster {
                gameMasterPanel.isHidden = false
                playerInfoWrapper.isHidden = true
                togglePlayerInfoButton.isHidden = true
                eventsController.set(events: turnSystem.getPresetEvents())
            } else {
                gameMasterPanel.isHidden = true
                playerInfoWrapper.isHidden = false
                togglePlayerInfoButton.isHidden = false
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

    /// Hides the player turn related panels
    private func playerTurnEnd() {
        actionPanelView.isHidden = true
        toggleActionPanelButton.isHidden = true
        countdownLabel.set(isHidden: true)
        portInformationView.isHidden = true
        availableUpgradesDataSource.enabled = false
        availableUpgradesTableView.reloadData()
        objectsController.resetChoosableNodes()
    }

    /// Get quantity selected for trade operations.
    ///
    /// - Returns: The trade quantity selected by the player.
    private func getTradeQuantity() -> Int {
        return Int(portQuantityLabel.text ?? "0") ?? 0
    }
}

extension MainGameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameAndBackgroundWrapper
    }
}

extension MainGameViewController: EventTableControllerDelegate {
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
        guard let currentTurnOwner = currentTurnOwner else {
            return
        }

        guard quantity > 0 else {
            let alert = ControllerUtils.getGenericAlert(titled: "Invalid Quantity",
                                                        withMsg: "Please make sure the quantity is above 0.")
            self.present(alert, animated: true, completion: nil)
            return
        }

        var errorMsg: String?
        do {
            switch action {
            case .playerBuy(let itemParameter):
                try turnSystem?.buy(itemParameter: itemParameter, quantity: quantity, by: currentTurnOwner)
            case .playerSell(let itemParameter):
                try turnSystem?.sell(itemParameter: itemParameter, quantity: quantity, by: currentTurnOwner)
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
        turnSystem?.acknowledgeTurnStart()
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

extension MainGameViewController: AvailableUpgradesControllerDelegate {
    func buy(upgrade: Upgrade) {
        guard let currentTurnOwner = currentTurnOwner else {
            return
        }

        var msg: String?
        var title: String? = "Error"
        do {
            let result = try turnSystem?.purchase(upgrade: upgrade, by: currentTurnOwner)
            msg = result?.getMessage()
            title = result?.getTitle()
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
}
