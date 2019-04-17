//
//  MainMenuViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.window?.rootViewController = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menuToLocalRoom" {
            guard let roomController = segue.destination as? WaitingRoomViewController,
                let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
                    let alert = ControllerUtils.getGenericAlert(titled: "Error",
                        withMsg: "An error has occured. Please try again later.")
                    present(alert, animated: true)
                    return
            }

            roomController.roomConnection = LocalRoomConnection(deviceId: deviceId)
        }
    }
}
