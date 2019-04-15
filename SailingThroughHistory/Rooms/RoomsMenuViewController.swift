//
//  File.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class RoomsMenuViewController: UIViewController {
    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var backButton: UIButtonRounded! {
        didSet {
            backButton.set(color: .red)
        }
    }

    private lazy var dataSource = RoomsTableDataSource(withView: roomsTableView, mainController: self)
    private var roomConnection: RoomConnection?
    private var canJoinRoom = true

    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.dataSource = dataSource
        roomsTableView.reloadData()
    }

    @IBAction func createRoomButtonPressed(_ sender: UIButton) {
        let alert = UIAlert(title: "Input name: ", confirm: { [weak self] roomName in
            self?.join(room: NetworkFactory.createRoomInstance(named: roomName))
            }, textPlaceHolder: "Input name here.")
        alert.present(in: self)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func join(room: Room) {
        if !canJoinRoom {
            let alert = ControllerUtils.getGenericAlert(titled: "You cannot join multiple rooms.", withMsg: "")
            self.present(alert, animated: true, completion: nil)
        }

        canJoinRoom = false
        room.getConnection { [weak self] (connection, error) in
            guard let connection = connection, error == nil else {
                let alert = ControllerUtils.getGenericAlert(titled: "Error joining room.", withMsg: "") {
                    self?.dismiss(animated: true, completion: nil)
                }
                self?.present(alert, animated: true, completion: nil)
                self?.canJoinRoom = true
                return
            }

            self?.roomConnection = connection
            self?.performSegue(withIdentifier: "roomsToWaitingRoom", sender: nil)
            self?.canJoinRoom = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "roomsToWaitingRoom",
            let nextController = segue.destination as? WaitingRoomViewController,
            let roomConnection = self.roomConnection else {
                return
        }

        nextController.roomConnection = roomConnection
    }
}
