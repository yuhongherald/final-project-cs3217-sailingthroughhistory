//
//  ViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 14/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit
import RxSwift

class MainGameViewController: UIViewController {
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
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var toggleActionPanelButton: UIButtonRounded!
    @IBOutlet private weak var actionPanelView: UIView!
    @IBOutlet private weak var rollDiceButton: UIButtonRounded! {
        didSet {
            rollDiceButton.set(color: .red)
        }
    }

    let scheduler = SerialDispatchQueueScheduler(qos: .default)
    var views = [GameObject: UIView]()
    var paths = [GameObject: [Path]]()
    let disposeBag = DisposeBag()
    // TODO: Change to actual game state.
    let interface = Interface()
    var subscription: Disposable?
    var originalScale: CGFloat = 1

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initBackground()

        //Uncomment to test interface
        /*let object = GameObject(image: "ship.png", frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        self.interface.add(object: object)
        let object2 = GameObject(image: "sea-node.png", frame: CGRect(x: 500, y: 500, width: 50, height: 50))
        self.interface.add(object: object2)
        self.interface.broadcastInterfaceChanges(withDuration: 3)
        self.interface.add(path: Path(fromObject: object, toObject: object2))
        self.interface.broadcastInterfaceChanges(withDuration: 1)*/

        subscribeToInterface()

         //Uncomment to test interface
         /*DispatchQueue.global(qos: .background).async { [weak self] in
            while true {
                object.frame = object.frame.applying(CGAffineTransform(translationX: 50, y: 50))
                self?.interface.updatePosition(of: object)
                self?.interface.broadcastInterfaceChanges(withDuration: 1)
            }
        }*/
    }

    @IBAction func toggleActionPanel(_ sender: UIButtonRounded) {
        actionPanelView.isHidden.toggle()
    }

    @IBAction func hidePortInformationPressed(_ sender: Any) {
        portInformationView.isHidden = false
    }

    @IBAction func rollDiceButtonPressed(_ sender: UIButtonRounded) {
        sender.isEnabled = false
        sender.set(color: .lightGray)
        /// TODO: Roll dice logic
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
        guard let image = UIImage(named: interface.background) else {
            return
        }

        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.image = image
    }

    private func subscribeToInterface() {
        interface.objectFrames.forEach {
            add(object: $0.key, at: $0.value, withDuration: 0.25, callback: {})
        }

        interface.paths.keys.forEach { [weak self] in
            interface.paths[$0]?.forEach { path in
                self?.add(path: path, fadeInDuration: 0.25, callback: {})
            }
        }

        interface.subscribe { [weak self] in
            guard let events = $0.element else {
                return
            }

            self?.handle(events: events)
        }
    }

    private func add(path: Path, fadeInDuration: TimeInterval, callback: @escaping () -> Void) {
        if paths[path.fromObject] == nil {
            paths[path.fromObject] = []
        }

        if paths[path.toObject] == nil {
            paths[path.toObject] = []
        }

        if paths[path.toObject]?.contains(path) ?? false && paths[path.fromObject]?.contains(path) ?? false {
            return
        }

        self.paths[path.fromObject]?.append(path)
        self.paths[path.toObject]?.append(path)
        guard let fromFrame = views[path.fromObject]?.frame,
            let toFrame = views[path.toObject]?.frame else {
                return
        }
        let startPoint = CGPoint(x: fromFrame.midX, y: fromFrame.midY)
        let endPoint = CGPoint(x: toFrame.midX, y: toFrame.midY)
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        layer.path = path.cgPath
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 4.0
        layer.lineDashPattern = [10.0, 2.0]
        gameArea.layer.addSublayer(layer)
        CATransaction.begin()
        CATransaction.setCompletionBlock(callback)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        /* set up animation */
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = fadeInDuration
        layer.add(animation, forKey: "drawLineAnimation")
        CATransaction.commit()

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
            add(path: path, fadeInDuration: duration, callback: callback)
        case .addObject(let object, let frame):
            add(object: object, at: frame, withDuration: duration, callback: callback)
        case .changeMonth(let newMonth):
            changeMonth(to: newMonth, withDuration: duration, callback: callback)
        case .playerTurnStart:
            playerTurnStart()
        case .pauseAndShowAlert(let title, let msg):
            pauseAndShowAlert(titled: title, withMsg: msg, callback: callback)
        default:
            print("Unsupported event not handled.")
        }
    }

    private func pauseAndShowAlert(titled title: String, withMsg msg: String, callback: @escaping () -> Void) {
        let alert = ControllerUtils.getGenericAlert(titled: title, withMsg: msg, action: callback)

        present(alert, animated: true, completion: nil)
    }

    private func playerTurnStart() {
        /// TODO: Update with actual player "name"
        let alert = ControllerUtils.getGenericAlert(titled: "Your turn has started.",
                                                    withMsg: "", action: { [weak self] in
                self?.actionPanelView.isHidden = false
                self?.toggleActionPanelButton.isHidden = false
            })

        present(alert, animated: true, completion: nil)
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
        let view = UIImageView(image: image)
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
