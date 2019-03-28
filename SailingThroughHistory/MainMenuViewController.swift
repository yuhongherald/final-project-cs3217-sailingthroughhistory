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
    var connection: RoomConnection?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to test
        /*let room = FirestoreRoom(named: "TestRoom", firestore: Firestore.firestore())
        room.getConnection(removalCallback: { print("Dead") }) { [weak self] in
            self?.connection = $0
        }*/
    }
}
