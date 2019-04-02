//
//  MenuViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/24/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

protocol MenuViewDelegateProtocol: class {
    func assign(port: Port, to team: Team?)
}

class MenuViewController: UITableViewController {
    var data: [Team] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var port: Port?
    weak var delegate: MenuViewDelegateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isUserInteractionEnabled = true
        self.tableView.isScrollEnabled = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)

        cell.textLabel?.text = data[indexPath.item].name
        cell.textLabel?.textAlignment = .center

        if let portOwner = port?.owner, portOwner == data[indexPath.item] {
            cell.backgroundColor = .gray
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let unwrappedPort = port else {
            return
        }

        if let portOwner = port?.owner, portOwner == data[indexPath.item] {
            self.delegate?.assign(port: unwrappedPort, to: nil)
        } else {
            self.delegate?.assign(port: unwrappedPort, to: data[indexPath.item])
        }

    }

    func set(port: Port) {
        self.port = port
        self.tableView.reloadData()
    }

}
