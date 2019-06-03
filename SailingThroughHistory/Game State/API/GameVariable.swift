//
//  GameVariable.swift
//  SailingThroughHistory
//
//  Created by henry on 17/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

/// Serves as an adapter between RxSwift and what is required by the project.

import Foundation
import RxSwift

class GameVariable<Element> : ObservableVariable {
    var value: Element {
        get {
            return variable.value
        }
        set(value) {
            variable.value = value
        }
    }
    private let disposeBag = DisposeBag()
    private var variable: Variable<Element>

    init(value: Element) {
        variable = Variable(value)
    }

    func subscribe(onNext: @escaping (Element) -> Void, onError: @escaping (Error?) -> Void,
                   onDisposed: (() -> Void)?) {
        variable.asObservable()
            .subscribe(onNext: onNext, onError: onError, onCompleted: nil, onDisposed: onDisposed)
            .disposed(by: disposeBag)
    }

    func subscribe(with observer: @escaping (Element) -> Void) {
        variable.asObservable()
            .subscribe(onNext: observer, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }

}
