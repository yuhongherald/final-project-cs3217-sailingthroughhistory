//
//  EventTableController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class EventTableController: NSObject {
    private static let reuseIdentifier = "eventCell"
    private var events: [PresetEvent]
    private weak var tableView: UITableView?
    private weak var mainController: MainGameViewController?

    init(tableView: UITableView, events: [PresetEvent], mainController: MainGameViewController) {
        self.tableView = tableView
        self.events = events
        self.mainController = mainController
        self.tableView?.reloadData()
    }

    func set(events: [PresetEvent]) {
        self.events = events
        self.tableView?.reloadData()
    }
}

extension EventTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: EventTableController.reuseIdentifier, for: indexPath) as? UIEventTableCell else {
                fatalError("Event cell is of the wrong type.")
        }

        let event = events[indexPath.row]
        let triggered = event.active
        cell.set(label: event.displayName)
        cell.set(buttonLabel: triggered ? "Turn Off" : "Turn On")
        cell.buttonPressedCallback = {  [weak self] in
            self?.mainController?.toggle(event: event, enabled: !triggered)
            self?.tableView?.reloadData()
        }

        return cell
    }
}
