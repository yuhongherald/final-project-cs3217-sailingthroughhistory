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

    private lazy var dataSource = RoomsTableDataSource(withView: roomsTableView)

    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.dataSource = dataSource
        roomsTableView.reloadData()
    }
}
