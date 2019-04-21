//
//  ObjectsViewControllerDelegate.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Delegate for ObjectsVIewController. Notified when it is appropriate to show the information of a given port.
protocol ObjectsViewControllerDelegate: class {
    func showInformation(of port: Port)
}
