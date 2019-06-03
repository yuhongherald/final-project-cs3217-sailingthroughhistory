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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButtonRounded! {
        didSet {
            backButton.set(color: .red)
        }
    }

    private lazy var dataSource = RoomsTableDataSource(withView: roomsTableView, mainController: self)
    private var roomConnection: RoomConnection?

    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.dataSource = dataSource
        roomsTableView.reloadData()
        activityIndicator.isHidden = true
    }

    @IBAction func createRoomButtonPressed(_ sender: UIButton) {
        let alert = ControllerUtils.getTextfieldAlert(title: "Input name: ", desc: "",
            textPlaceHolder: "Input name here.",
            okAction: { [weak self] roomName in
            let room: Room
            do {
                room = try NetworkFactory.createRoomInstance(named: roomName)
                self?.join(room: room)
            } catch {
                let error = error as? StorageError
                let alert = ControllerUtils.getGenericAlert(titled: "Create Room Failed.",
                    withMsg: error?.getMessage() ?? "Error connectiong to room.")
                self?.present(alert, animated: true, completion: nil)
            }
        }, cancelAction: nil)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func join(room: Room) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        room.getConnection { [weak self] (connection, error) in
            guard let connection = connection, error == nil else {
                let alert = ControllerUtils.getGenericAlert(titled: "Error joining room.", withMsg: "")
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.present(alert, animated: true, completion: nil)
                return
            }

            self?.roomConnection = connection
            self?.performSegue(withIdentifier: "roomsToWaitingRoom", sender: nil)
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "roomsToWaitingRoom",
            let nextController = segue.destination as? WaitingRoomViewController,
            let roomConnection = self.roomConnection else {
                print("Segue to waiting room failed.")
                return
        }

        nextController.roomConnection = roomConnection
    }
}
