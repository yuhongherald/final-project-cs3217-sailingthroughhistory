//
//  EventTableController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 15/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// The controller for the event table used in the GM panel.
class EventTableController: NSObject {
    private static let reuseIdentifier = "eventCell"
    private var events: [PresetEvent]
    private weak var tableView: UITableView?
    private weak var delegate: EventTableControllerDelegate?

    /// Constructor for a controller that uses the input table view to show events, the input events and a delegate to
    /// notify when the user chooses to toggle events.
    ///
    /// - Parameters:
    ///   - tableView: The table view to show the events on.
    ///   - events: The current events.
    ///   - delegate: The delegate to notify on user action.
    init(tableView: UITableView, events: [PresetEvent], delegate: EventTableControllerDelegate) {
        self.tableView = tableView
        self.events = events
        self.delegate = delegate
        self.tableView?.reloadData()
    }

    /// Sets the events shown to the ones in the input
    ///
    /// - Parameter events: The array of PresetEvent to show
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
            self?.delegate?.toggle(event: event, enabled: !triggered)
            self?.tableView?.reloadData()
        }

        return cell
    }
}
