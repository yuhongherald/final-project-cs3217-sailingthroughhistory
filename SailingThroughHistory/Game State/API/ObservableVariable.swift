//
//  ObservableVariable.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Serves as an adapter for observable containers

import Foundation

protocol ObservableVariable {
    associatedtype Element: Any
    func subscribe(onNext: @escaping (Element) -> Void, onError: @escaping (Error?) -> Void, onDisposed: (() -> Void)?)
    func subscribe(with observer: @escaping (Element) -> Void)
}
