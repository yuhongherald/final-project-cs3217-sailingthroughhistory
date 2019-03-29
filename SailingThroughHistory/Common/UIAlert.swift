//
//  Alert.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class UIAlert {
    private var controller: UIAlertController!

    init(title: String, msg: String? = nil, confirm: @escaping (String)->Void,
         textPlaceHolder: String) {
        controller = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Confirm",
                                       style: .default,
                                       handler: { _ in
                                        guard let name = self.controller.textFields?.first?.text else {
                                            return
                                        }
                                        confirm(name)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        controller.addTextField { (textFiled: UITextField) in
            textFiled.keyboardAppearance = .default
            textFiled.keyboardType = .default
            textFiled.placeholder = textPlaceHolder
            textFiled.clearButtonMode = .whileEditing
        }
        controller.addAction(saveAction)
        controller.addAction(cancelAction)
    }

    init(errorMsg: String, msg: String?) {
        controller = UIAlertController(title: errorMsg, message: msg, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        controller.addAction(cancelAction)
    }

    func present(in controller: UIViewController) {
        controller.present(controller, animated: true, completion: nil)
    }
}
