//
//  GamePublishSubject.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import RxSwift

class InterfacePublishSubject<Element> {
    let disposeBag = DisposeBag()
    let publishSubject = PublishSubject<Element>()

    func on(next: Element) {
        publishSubject.onNext(next)
    }

    func subscribe(callback: @escaping (Event<Element>) -> Void) {
        return publishSubject.observeOn(SerialDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(callback)
            .disposed(by: disposeBag)
    }
}
