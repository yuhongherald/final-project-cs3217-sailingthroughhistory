//
//  MenuViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/24/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

protocol MenuViewDelegateProtocol: class {
    func assign(port: Port, to player: PlayerParameter)
}

class MenuViewController: UITableViewController {
    var data: [PlayerParameter] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var port: Port?
    weak var delegate: MenuViewDelegateProtocol?

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

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

        cell.textLabel?.text = data[indexPath.item].getName()
        cell.textLabel?.textAlignment = .center

        if data[indexPath.item].getPort() == port && port != nil {
            cell.backgroundColor = .gray
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let unwrappedPort = port else {
            return
        }
        self.delegate?.assign(port: unwrappedPort, to: data[indexPath.item])
    }

    func set(port: Port) {
        self.port = port
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
