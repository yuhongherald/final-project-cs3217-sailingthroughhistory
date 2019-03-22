//
//  GameVariable.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import Foundation
import RxSwift

class GameVariable<T> : ObservableVariable {
    var value: T {
        get {
            return variable.value
        }
        set(value) {
            variable.value = value
        }
    }
    private let disposeBag = DisposeBag()
    private var variable: Variable<T>

    init(value: T) {
        variable = Variable(value)
    }

    func subscribe(with observer: @escaping (Event<T>) -> Void) {
        variable.asObservable().subscribe(observer).disposed(by: disposeBag)
    }

}
