//
//  AlertQueueViewController.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 18/4/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class AlertQueueController: UIViewController {
    private var alertQueue = [UIViewController]()

    func getGenericAlert(titled title: String, withMsg msg: String, okAction: (() -> Void)?) -> UIAlertController {
        return ControllerUtils.getGenericAlert(titled: title, withMsg: msg) { [weak self] in
            /*guard let self = self else {
                return
            }
            okAction?()
            if !self.alertQueue.isEmpty {
                self.present(self.alertQueue.removeFirst(), animated: true, completion: nil)
            }*/
            okAction?()
        }
    }

    func presentStack(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        var cur: UIViewController = self
        while let next = cur.presentingViewController {
            cur = next
        }
        cur.present(viewControllerToPresent, animated: true, completion: nil)
    }
}
