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
    private lazy var pathsController: PathsViewController = PathsViewController(view: gameArea, mainController: self)
    private lazy var objectsController: ObjectsViewController =
        ObjectsViewController(view: gameArea, mainController: self)
    private lazy var togglablePanels: [UIButton: UIView] = [
        toggleActionPanelButton: actionPanelView,
        togglePlayerOneInfoButton: playerOneInformationView,
        togglePlayerTwoInfoButton: playerTwoInformationView]
    private lazy var portItemsDataSource = PortItemTableDataSource(mainController: self)
    private var playerItemsDataSources = [PlayerItemsTableDataSource]()
    private var model: GameState?

    var interfaceBounds: CGRect {
        /// TODO: Fix
        if let map = model?.map {
            return CGRect(fromRect: map.bounds)
        }
        return CGRect()
        //return CGRect(fromRect: interface.bounds)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reInitScrollView()
        initBackground()

        //model.map?.getNodes().forEach { node in }
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
        /// TODO: FIx
        /*guard let image = UIImage(named: interface.background),
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
        backgroundImageView.image = image*/
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

    private func subscribePlayerInformation(players: [GenericPlayer]) {
        /// TODO: Less hackish
        /*if players.indices.contains(0) {
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
        }*/
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

    private func playerTurnStart(player: GenericPlayer, timeLimit: TimeInterval?, timeOutCallback: (() -> Void)?,
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
                        timeOutCallback?()
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
