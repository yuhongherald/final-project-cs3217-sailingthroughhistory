//
//  Observable.swift
//  SailingThroughHistory
//
//  Created by Herald on 28/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

protocol Observable {
    func addObserver(event: TurnSystemEvent)
    func removeObserver(event: TurnSystemEvent)
}
