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
        guard segue.identifier == "waitingRoomToGallery",
            let galleryController = segue.destination as? GalleryViewController else {
                return
        }

        galleryController.selectedCallback = { [weak self] gameParameter in
            self?.waitingRoom?.parameters = gameParameter
            galleryController.dismiss(animated: true, completion: nil)
        }
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
