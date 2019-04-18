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
    func start(from node: Node, for team: Team)
    func getEditingMode(for gesture: UIGestureRecognizer) -> EditMode?
}

class TeamMenuDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView? {
        didSet {
            self.tableView?.isUserInteractionEnabled = true
            self.tableView?.isScrollEnabled = false
        }
    }
    var data: [Team] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    var node: Node?
    weak var delegate: MenuViewDelegateProtocol?
    private var editMode: EditMode?

    // MARK: - Table view data source

    init(data: [Team], delegate: MenuViewDelegateProtocol?) {
        self.delegate = delegate
        self.data = data
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)

        cell.textLabel?.text = data[indexPath.item].name
        cell.textLabel?.textAlignment = .center

        guard editMode == .portOwnership else {
            return cell
        }

        if let unwrappedPort = node as? Port, let portOwner = unwrappedPort.owner, portOwner == data[indexPath.item] {
            cell.backgroundColor = .gray
        } else {
            cell.backgroundColor = .white
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTeam = data[indexPath.item]

        if editMode == .portOwnership, let unwrappedPort = node as? Port {
            if let portOwner = unwrappedPort.owner, portOwner == selectedTeam {
                self.delegate?.assign(port: unwrappedPort, to: nil)
            } else {
                self.delegate?.assign(port: unwrappedPort, to: data[indexPath.item])
            }
        }

        if editMode == .startingNode, let unwrappedNode = node {
            self.delegate?.start(from: unwrappedNode, for: selectedTeam)
        }
    }

    func set(node: Node, for gesture: UIGestureRecognizer) {
        self.node = node
        self.tableView?.reloadData()
        self.editMode = delegate?.getEditingMode(for: gesture)
    }
}
