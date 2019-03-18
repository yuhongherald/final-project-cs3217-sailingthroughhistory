//
//  ObservableVariable.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import RxSwift

protocol ObservableVariable {
    associatedtype T: Any
    func subscribe(with observer: @escaping (Event<T>) -> Void)
}
