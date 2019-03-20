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
    private static let allowAllAspectRatio = true

    @IBOutlet private weak var gameAndBackgroundWrapper: UIView!
    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 3
        }
    }
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var gameArea: UIView!
    @IBOutlet private weak var portInformationView: UIView! {
        didSet {
            addBlurBackground(to: portInformationView)
        }
    }
    @IBOutlet private weak var playerOneInformationView: UIView! {
        didSet {
            addBlurBackground(to: playerOneInformationView)
        }
    }
    @IBOutlet private weak var playerTwoInformationView: UIView! {
        didSet {
            addBlurBackground(to: playerTwoInformationView)
        }
    }
    @IBOutlet private weak var countdownLabel: CountdownLabel!
    @IBOutlet private weak var playerOneGoldView: UILabel!
    @IBOutlet private weak var playerTwoGoldView: UILabel!
    @IBOutlet private weak var togglePlayerOneInfoButton: UIButtonRounded!
    @IBOutlet private weak var togglePlayerTwoInfoButton: UIButtonRounded!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var toggleActionPanelButton: UIButtonRounded!
    @IBOutlet private weak var diceResultLabel: UILabel!
    @IBOutlet private weak var actionPanelView: UIView!
    @IBOutlet private weak var rollDiceButton: UIButtonRounded! {
        didSet {
            rollDiceButton.set(color: .red)
        }
    }

    var views = [GameObject: UIGameImageView]()
    /// TODO: Reference to Game Engine
    private lazy var interface: Interface = Interface(players: [], bounds: backgroundImageView.frame)
    private lazy var pathsController: PathsViewController = PathsViewController(view: gameArea, mainController: self)
    private lazy var togglablePanels: [UIButton: UIView] = [
        toggleActionPanelButton: actionPanelView,
        togglePlayerOneInfoButton: playerOneInformationView,
        togglePlayerTwoInfoButton: playerTwoInformationView]

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initBackground()
        //Uncomment to test interface
        let object = GameObject(image: "ship.png", frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        self.interface.add(object: object)
        let object2 = Node(name: "testnode", image: "sea-node.png", frame: CGRect(x: 500, y: 500, width: 50, height: 50))
        let path = Path(from: object, to: object2)
        self.interface.add(object: object2)
        self.interface.broadcastInterfaceChanges(withDuration: 3)
        self.interface.add(path: path)
        self.interface.broadcastInterfaceChanges(withDuration: 1)
        self.interface.remove(path: path)
        self.interface.showTravelChoices([object2]) { [weak self] (_: GameObject)  in
            let alert = ControllerUtils.getGenericAlert(titled: "Title", withMsg: "Msg")
            self?.present(alert, animated: true, completion: nil)
            }
        //TODO
        /*self.interface.playerTurnStart(player: Player(node: object2), timeLimit: 120) { [weak self] in
            let alert = ControllerUtils.getGenericAlert(titled: "Time up!", withMsg: "Msg")
            self?.present(alert, animated: true, completion: nil)
        }*/

        subscribeToInterface()

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
        return views[object]?.frame
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
        guard let gameView = view as? UIGameImageView,
            gameView.tapCallback != nil,
            gameView.object as? Node != nil else {
            return
        }

        gameView.callTapCallback()

        // Remove glow/callback from nodes.
        views.values
            .filter { $0.object as? Node != nil }
            .forEach {
                $0.removeGlow()
                $0.tapCallback = nil
                $0.isUserInteractionEnabled = false
        }
    }

    private func addBlurBackground(to view: UIView) {
        view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.frame = view.bounds
        blurView.alpha = 0.7
        view.insertSubview(blurView, at: 0)
    }

    private func initBackground() {
        guard let image = UIImage(named: interface.background),
            let gameAndBackgroundWrapper = self.gameAndBackgroundWrapper,
            let oldScrollView = self.scrollView else {
            return
        }

        if MainGameViewController.allowAllAspectRatio {
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

            backgroundImageView.contentMode = .topLeft
            backgroundImageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
            gameAndBackgroundWrapper.frame = backgroundImageView.frame
            gameArea.frame = backgroundImageView.frame

            scrollView.contentSize = image.size
            scrollView.minimumZoomScale = max(view.frame.height/image.size.height, view.frame.width/image.size.width)
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            backgroundImageView.contentMode = .scaleToFill
        }

        backgroundImageView.image = image
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
            add(object: $0.key, at: $0.value, withDuration: 0.25, callback: {})
        }

        interface.paths.keys.forEach { [weak self] in
            interface.paths[$0]?.forEach { path in
                self?.pathsController.add(path: path, withDuration: 0.25, callback: {})
            }
        }
    }

    private func subscribePlayerInformation(players: [Player]) {
        /// TODO: Less hackish
        if players.indices.contains(0) {
            players[0].money.subscribe { [weak self] in
                guard let gold = $0.element else {
                    self?.playerOneGoldView.text = "\(InterfaceConstants.moneyPrefix)Error"
                    return
                }

                self?.playerOneGoldView.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
            }
        }

        if players.indices.contains(1) {
            players[1].money.subscribe { [weak self] in
                guard let gold = $0.element else {
                    self?.playerTwoGoldView.text = "\(InterfaceConstants.moneyPrefix)Error"
                    return
                }

                self?.playerTwoGoldView.text = "\(InterfaceConstants.moneyPrefix)\(gold)"
            }
        }
    }

    private func remove(object: GameObject, withDuration duration: TimeInterval, callback: @escaping () -> Void) {
        let view = views[object]
        pathsController.removeAllPathsAssociated(with: object, withDuration: duration)
        UIView.animate(withDuration: duration, animations: {
            view?.alpha = 0
        }, completion: { _ in
            view?.removeFromSuperview()
            callback()
        })
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
            move(object: object, to: dest, withDuration: duration, callback: callback)
        case .addPath(let path):
            pathsController.add(path: path, withDuration: duration, callback: callback)
        case .addObject(let object, let frame):
            add(object: object, at: frame, withDuration: duration, callback: callback)
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
            makeChoosable(nodes: nodes, withDuration: duration, tapCallback: selectCallback, callback: callback)
        default:
            print("Unsupported event not handled.")
        }
    }

    private func makeChoosable(nodes: [Node], withDuration duration: TimeInterval, tapCallback: @escaping (GameObject) -> Void, callback: @escaping () -> Void) {
        if nodes.isEmpty {
            callback()
            return
        }

        nodes.forEach { [weak self] in
            self?.views[$0]?.isUserInteractionEnabled = true
            self?.views[$0]?.tapCallback = tapCallback
        }

        UIView.animate(withDuration: duration, animations: {
            nodes.forEach { [weak self] in
                self?.views[$0]?.addGlow(colored: .purple)
            }
        }, completion: { _ in
            callback()
        })
        /// TODO: Add callback to engine
    }

    private func pauseAndShowAlert(titled title: String, withMsg msg: String, callback: @escaping () -> Void) {
        let alert = ControllerUtils.getGenericAlert(titled: title, withMsg: msg, action: callback)

        present(alert, animated: true, completion: nil)
    }

    private func playerTurnStart(player: Player, timeLimit: TimeInterval?, timeOutCallback: @escaping () -> Void,
                                 callback: @escaping () -> Void) {
        let alert = ControllerUtils.getGenericAlert(titled: "\(player.name)'s turn has started.",
            withMsg: "")
        { [weak self] in
            self?.actionPanelView.isHidden = false
            self?.toggleActionPanelButton.isHidden = false
            if let timeLimit = timeLimit {
                self?.countdownLabel.isHidden = false
                self?.countdownLabel.animationType = CountdownEffect.Burn
                self?.countdownLabel.setCountDownTime(
                    minutes: timeLimit)
                self?.countdownLabel.then(targetTime: 1) { [weak self] in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        timeOutCallback()
                        self?.playerTurnEnd()
                    }
                }
                self?.countdownLabel.start()
            }
            callback()
        }

        present(alert, animated: true, completion: nil)
    }

    private func playerTurnEnd() {
        actionPanelView.isHidden = true
        toggleActionPanelButton.isHidden = true
        countdownLabel.isHidden = true
    }

    private func move(object: GameObject, to dest: CGRect, withDuration duration: TimeInterval,
                      callback: @escaping () -> Void) {
        guard let objectView = views[object] else {
            return
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { [unowned self] in
            objectView.frame = CGRect.translatingFrom(otherBounds: self.interface.bounds, otherFrame: dest,
                                                      to: self.gameArea.bounds)
            }, completion: { _ in callback() })
    }

    private func add(object: GameObject, at frame: CGRect, withDuration duration: TimeInterval,
                     callback: @escaping () -> Void) {
        views[object]?.removeFromSuperview()
        let image = UIImage(named: object.image)
        let view = UIGameImageView(image: image, object: object)
        views[object] = view
        view.alpha = 0
        gameArea.addSubview(view)
        view.frame = CGRect.translatingFrom(otherBounds: interface.bounds, otherFrame: frame, to: gameArea.bounds)
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: { _ in callback() })
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
