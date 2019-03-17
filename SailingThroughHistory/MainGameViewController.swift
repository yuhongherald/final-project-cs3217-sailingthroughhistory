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
    private static let enablePan = true

    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var gameArea: UIView!
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
        if let image = UIImage(named: interface.background) {
            backgroundImageView.contentMode = .topLeft
            backgroundImageView.image = image
            backgroundImageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
            gameArea.frame = backgroundImageView.frame
        }

        interface.events.observeOn(SerialDispatchQueueScheduler(qos: .userInteractive)).subscribe { [weak self] in
            guard let events = $0.element else {
                return
            }

            self?.handle(events: events)
        }.disposed(by: disposeBag)
        /*
         Uncomment to test interface
         DispatchQueue.global(qos: .background).async { [weak self] in
            let object = GameObject(image: "ship.png", frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            self?.interface.add(object: object)
            self?.interface.broadcastInterfaceChanges(withDuration: 3)
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

    @IBAction func rollDiceButtonPressed(_ sender: UIButtonRounded) {
        sender.isEnabled = false
        sender.set(color: .lightGray)
        /// TODO: Roll dice logic
    }

    @IBAction func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        if !MainGameViewController.enablePan {
            return
        }

        let views = [backgroundImageView, gameArea]
        if sender.state == .changed {
            let scale = sender.scale * originalScale
            views.forEach {
                $0?.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else if sender.state == .began || sender.state == .ended {
            originalScale = backgroundImageView.transform.a
        }
    }

    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        if !MainGameViewController.enablePan {
            return
        }
        let translation = sender.translation(in: sender.view)
        let views = [backgroundImageView, gameArea]
        if sender.state == .changed {
            views.forEach {
                var transform = CGAffineTransform(scaleX: originalScale, y: originalScale)
                transform = transform.concatenating(CGAffineTransform(translationX: translation.x, y: translation.y)
                )
                $0?.transform = transform
            }
        } else if sender.state == .ended {
            views.forEach {
                guard let view = $0 else {
                    return
                }
                let frame = view.frame
                view.transform = view.transform.concatenating(
                    CGAffineTransform(translationX: -translation.x, y: -translation.y))
                view.frame = frame
            }
        }
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
        case .add(let object, let frame):
            add(object: object, at: frame, withDuration: duration, callback: callback)
        case .changeMonth(let newMonth):
            changeMonth(to: newMonth, withDuration: duration, callback: callback)
        case .playerTurnStart:
            playerTurnStart()
        default:
            print("Unsupported event not handled.")
        }
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
