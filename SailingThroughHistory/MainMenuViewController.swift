//
//  MainMenuViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MainMenuViewController: UIViewController {
    var connection = [RoomConnection?]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to test
       /* var room = FirestoreRoom(named: "TestRoom")
        room.getConnection(removalCallback: { print("Dead") }) { [weak self] (con, _) in
            self?.connection.append(con)
        }
        room = FirestoreRoom(named: "TestRoom2")
        room.getConnection(removalCallback: { print("Dead") }) { [weak self] (con, _) in
            self?.connection.append(con)
        }
        room = FirestoreRoom(named: "TestRoom3")
        room.getConnection(removalCallback: { print("Dead") }) { [weak self] (con, _) in
            self?.connection.append(con)
        }*/
    }
}
