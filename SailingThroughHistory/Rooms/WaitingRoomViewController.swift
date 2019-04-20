//
//  WaitingRoomViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class WaitingRoomViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
    private var gameRoom: GameRoom?
    private var initialState: GenericGameState?
    private var imageData: Data?

    override func viewDidAppear(_ animated: Bool) {
        roomConnection?.changeRemovalCallback { [weak self] in
            let alert = ControllerUtils.getGenericAlert(titled: "You are removed from room.", withMsg: "", action: {
                self?.dismissWithDisconnect()
            })
            self?.present(alert, animated: true, completion: nil)
        }
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        guard let roomConnection = roomConnection else {
            let alert = ControllerUtils.getGenericAlert(titled: "Error getting connection",
                                                        withMsg: "") { [weak self] in
                                                            self?.dismissWithDisconnect()
            }
            present(alert, animated: true, completion: nil)
            return
        }
        let waitingRoom = GameRoom(fromConnection: roomConnection)
        subscribeToGameStart()
        self.gameRoom = waitingRoom
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
        dismissWithDisconnect()
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
            self?.gameRoom?.parameters = gameParameter
        }
    }

    private func prepareForSegueToGame(segue: UIStoryboardSegue) {
        guard let roomConnection = roomConnection,
            let initialState = initialState,
            let imageData = imageData,
            let gameController = segue.destination as? MainGameViewController else {
            return
        }

        let turnSystemState = TurnSystemState(gameState: initialState, joinOnTurn: 0)
        let networkInfo = NetworkInfo(getWaitingRoom().identifier,
                                      getWaitingRoom().isRoomMaster())

        // TODO: Create setContext() method instead of initializing
        let playerActionAdapterFactory = PlayerActionAdapterFactory()
        let network = TurnSystemNetwork(
            roomConnection: roomConnection,
            playerActionAdapterFactory: playerActionAdapterFactory,
            networkInfo: networkInfo,
            turnSystemState: turnSystemState)
        let system = TurnSystem(network: network,
                                startingState: turnSystemState)
        gameController.turnSystem = system
        gameController.network = roomConnection
        gameController.backgroundData = imageData
    }

    @IBAction func startGamePressed(_ sender: Any) {
        if !getWaitingRoom().isRoomMaster() {
            showNotAuthorizedAlert()
            return
        }
        guard let (parameters, imageData) = getGameData() else {
            return
        }
        /// TODO: Remove hardcoded year
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        let state = GameState(baseYear: 1900, level: parameters, players: getWaitingRoom().players)
        do {
            try roomConnection?.startGame(initialState: state, background: imageData) { [weak self] error in
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
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
            self.activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
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
        var names = Set<String>()
        for member in getWaitingRoom().players {
            if names.contains(member.playerName) {
                let alert = ControllerUtils.getGenericAlert(titled: "Duplicate name found",
                                                            withMsg: "Each player must have a unique name.")
                present(alert, animated: true, completion: nil)
                return nil
            }
            if member.isGameMaster {
                if gmFound {
                    let alert = ControllerUtils.getGenericAlert(titled: "More than one GM found",
                        withMsg: "There can only be at most 1 Game Master.")
                    present(alert, animated: true, completion: nil)
                    return nil
                }
                gmFound = true
            } else if !member.hasTeam {
                let alert = ControllerUtils.getGenericAlert(titled: "\(member.identifier) has no team.",
                    withMsg: "Please make sure everyone has a team.")
                present(alert, animated: true, completion: nil)
                return nil
            }
            names.insert(member.playerName)
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

    func getWaitingRoom() -> GameRoom {
        guard let waitingRoom = gameRoom else {
            fatalError("Waiting room is nil.")
        }

        return waitingRoom
    }

    private func showNotAuthorizedAlert() {
        let alert = ControllerUtils.getGenericAlert(titled: "Action not allowed.",
                                                    withMsg: "You are not the room master.")
        present(alert, animated: true, completion: nil)
    }

    private func dismissWithDisconnect() {
        self.dismiss(animated: true, completion: nil)
        self.gameRoom?.disconnect()
    }
}
