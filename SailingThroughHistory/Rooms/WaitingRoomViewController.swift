//
//  WaitingRoomViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class WaitingRoomViewController: UIViewController {

    @IBOutlet weak var joinPlayerButton: UIButtonRounded!
    @IBOutlet private weak var chooseLevelButton: UIButtonRounded!
    @IBOutlet private weak var playersTableView: UITableView!
    @IBOutlet weak var backButton: UIButtonRounded! {
        didSet {
            backButton.set(color: .red)
        }
    }
    private var dataSource: MembersTableDataSource?
    var roomConnection: RoomConnection?
    private var waitingRoom: WaitingRoom?
    private var initialState: GenericGameState?
    private var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let roomConnection = roomConnection else {
            let alert = ControllerUtils.getGenericAlert(titled: "Error getting connection",
                                                        withMsg: "") { [weak self] in
                                                            self?.dismiss(animated: true, completion: nil)
            }
            present(alert, animated: true, completion: nil)
            return
        }
        let waitingRoom = WaitingRoom(fromConnection: roomConnection)
        subscribeToGameStart()
        self.waitingRoom = waitingRoom
        dataSource = MembersTableDataSource(withView: playersTableView, withRoom: waitingRoom, mainController: self)
        playersTableView.dataSource = dataSource
    }

    @IBAction func chooseLevelPressed(_ sender: Any) {
        if !getWaitingRoom().isRoomMaster() {
            showNotAuthorizedAlert()
            return
        }

        performSegue(withIdentifier: "waitingRoomToGallery", sender: nil)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func joinPlayerPressed(_ sender: Any) {
        roomConnection?.addPlayer()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "waitingRoomToGallery":
            prepareForSegueToGallery(segue: segue)
        case "waitingRoomToGame":
            prepareForSegueToGame(segue: segue)
        default:
            break
        }

    }

    private func prepareForSegueToGallery(segue: UIStoryboardSegue) {
        guard segue.identifier == "waitingRoomToGallery",
            let galleryController = segue.destination as? GalleryViewController else {
                return
        }

        galleryController.selectedCallback = { [weak self] gameParameter in
            self?.waitingRoom?.parameters = gameParameter
        }
    }

    private func prepareForSegueToGame(segue: UIStoryboardSegue) {
        guard let roomConnection = roomConnection,
            let initialState = initialState,
            let imageData = imageData,
            let gameController = segue.destination as? MainGameViewController else {
            return
        }

        let system = TurnSystem(isMaster: getWaitingRoom().isRoomMaster(),
                                network: roomConnection,
                                startingState: initialState,
                                deviceId: self.getWaitingRoom().identifier)
        gameController.turnSystem = system
        gameController.network = roomConnection
        gameController.backgroundData = imageData
    }

    @IBAction func startGamePressed(_ sender: Any) {
        guard let (parameters, imageData) = getGameData() else {
            return
        }
        /// TODO: Remove hardcoded year
        let state = GameState(baseYear: 1900, level: parameters, players: getWaitingRoom().players)
        do {
            try roomConnection?.startGame(initialState: state, background: imageData) { [weak self] error in
                guard let error = error else {
                    return
                }
                print(error)
                let alert = ControllerUtils.getGenericAlert(titled: "Failed to start game.",
                                                            withMsg: "Please try again later.")
                self?.present(alert, animated: true, completion: nil)
                }
        } catch {
            let alert = ControllerUtils.getGenericAlert(titled: "Failed to start game.",
                                                        withMsg: "Error in game level.")
            present(alert, animated: true, completion: nil)
        }
    }

    private func getGameData() -> (parameters: GameParameter, imageData: Data)? {
        guard !getWaitingRoom().players.isEmpty else {
            let alert = ControllerUtils.getGenericAlert(titled: "No players are registered.",
                                                        withMsg: "You cannot start a game with no players.")
            present(alert, animated: true, completion: nil)
            return nil
        }

        guard let parameters = getWaitingRoom().parameters else {
            let alert = ControllerUtils.getGenericAlert(titled: "Missing Level.",
                                                        withMsg: "Please choose a level first.")
            present(alert, animated: true, completion: nil)
            return nil
        }

        guard let imageData = LocalStorage().readImageData(parameters.map.map) else {
            let alert = ControllerUtils.getGenericAlert(titled: "Missing Image.",
                                                        withMsg: "Please choose a valid level first.")
            present(alert, animated: true, completion: nil)
            return nil
        }

        var gmFound = false
        for member in getWaitingRoom().players {
            if member.isGameMaster {
                if gmFound {
                    let alert = ControllerUtils.getGenericAlert(titled: "More than one GM found",
                        withMsg: "There can only be at most 1 Game Master.")
                    present(alert, animated: true, completion: nil)
                    return nil
                }
                gmFound = true
            } else if !member.hasTeam {
                let alert = ControllerUtils.getGenericAlert(titled: "\(member.playerName) has no team.",
                    withMsg: "Please make sure everyone has a team.")
                present(alert, animated: true, completion: nil)
                return nil
            }
        }

        return (parameters: parameters, imageData: imageData)
    }

    func subscribeToGameStart() {
        guard let roomConnection = roomConnection else {
            preconditionFailure("No connection to room.")
        }
        roomConnection.subscribeToStart { [weak self] (state, imageData) in
            guard let self = self else {
                return
            }
            self.imageData = imageData
            self.initialState = state
            self.performSegue(withIdentifier: "waitingRoomToGame", sender: nil)
        }
    }

    func getWaitingRoom() -> WaitingRoom {
        guard let waitingRoom = waitingRoom else {
            fatalError("Waiting room is nil.")
        }

        return waitingRoom
    }

    private func showNotAuthorizedAlert() {
        let alert = ControllerUtils.getGenericAlert(titled: "Action not allowed.",
                                                    withMsg: "You are not the room master.")
        present(alert, animated: true, completion: nil)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        roomConnection.disconnect()
    }
}
