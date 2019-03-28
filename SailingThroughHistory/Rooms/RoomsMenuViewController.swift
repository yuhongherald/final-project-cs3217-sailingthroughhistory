//
//  File.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class RoomsMenuViewController: UIViewController {
    private static let reuseIdentifier = "roomCell"

    @IBOutlet weak var roomsTableView: UITableView!

    var networkHelper = NetworkUIHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        networkHelper.bindRooms(to: roomsTableView,
                                withReuseIdentifier: RoomsMenuViewController.reuseIdentifier)
    }
}
