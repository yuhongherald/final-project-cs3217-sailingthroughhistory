//
//  WaitingRoomViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 1/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class WaitingRoomViewController: UIViewController {

    @IBOutlet private weak var changeTeamButton: UIButtonRounded!
    @IBOutlet private weak var chooseLevelButton: UIButtonRounded!
    @IBOutlet private weak var playersTableView: UITableView!
    private var dataSource: PlayersTableDataSource?
    var roomConnection: RoomConnection?
    private var waitingRoom: WaitingRoom?
    private var initialState: GenericGameState?

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
        self.waitingRoom = waitingRoom
        dataSource = PlayersTableDataSource(withView: playersTableView, withRoom: waitingRoom)
        playersTableView.dataSource = dataSource
    }

    @IBAction func chooseLevelPressed(_ sender: Any) {
        if !getWaitingRoom().isRoomMaster() {
            showNotAuthorizedAlert()
            return
        }

        performSegue(withIdentifier: "waitingRoomToGallery", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "waitingRoomToGallery":
            prepareForSegueToGallery(segue: segue)
            break
        case "waitingRoomToGame":
            prepareForSegueToGame(segue: segue)
            break
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
            galleryController.dismiss(animated: true, completion: nil)
        }
    }

    private func prepareForSegueToGame(segue: UIStoryboardSegue) {
        guard let roomConnection = roomConnection,
            let initialState = initialState,
            let gameController = segue.destination as? MainGameViewController else {
            return
        }

        let system = TurnSystem(isMaster: getWaitingRoom().isRoomMaster(), network: roomConnection, startingState: initialState, deviceId: self.getWaitingRoom().identifier)
        gameController.turnSystem = system
    }

    @IBAction func changeTeamPressed(_ sender: Any) {
        waitingRoom?.changeTeam()
    }

    @IBAction func startGamePressed(_ sender: Any) {
        guard getWaitingRoom().isRoomMaster() else {
                showNotAuthorizedAlert()
                return
        }

        guard let parameters = getWaitingRoom().parameters else {
            let alert = ControllerUtils.getGenericAlert(titled: "Missing Level.",
                                                        withMsg: "Please choose a level first.")
            present(alert, animated: true, completion: nil)
            return
        }

        /// TODO: Remove hardcoded year
        let state = GameState(baseYear: 1900, level: parameters, players: getWaitingRoom().players)
        do {
            try roomConnection?.startGame(initialState: state) { [weak self] error in
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

    func subscribeToGameStart() {
        guard let roomConnection = roomConnection else {
            preconditionFailure("No connection to room.")
        }
        roomConnection.subscribeToStart { [weak self] state in
            guard let self = self else {
                return
            }

            //let system = TurnSystem(isMaster: self.getWaitingRoom().isRoomMaster(), network: roomConnection, startingState: state, deviceId: self.getWaitingRoom().identifier)
            self.initialState = state
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
}
