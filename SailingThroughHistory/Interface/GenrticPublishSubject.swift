//
//  GamePublishSubject.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 19/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import RxSwift

class GenericPublishSubject<Element> {
    let disposeBag = DisposeBag()
    let publishSubject = PublishSubject<Element>()

    func on(next: Element) {
        publishSubject.onNext(next)
    }

    func subscribe(with observer: @escaping (Element) -> Void) {
        return publishSubject.observeOn(SerialDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: observer, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}
