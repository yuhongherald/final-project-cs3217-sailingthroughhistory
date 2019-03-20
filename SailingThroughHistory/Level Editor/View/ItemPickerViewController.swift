//
//  ItemTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

protocol ItemPickerDelegateProtocol {
    func pick(_ select: ItemType)
}

class ItemPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let confirmButton = UIButtonRounded()
    let cancelButton = UIButtonRounded()
    let pickerView = UIPickerView()
    var pickerData = ItemType.getAll()
    var selectedItem: ItemType?
    var delegate: ItemPickerDelegateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.delegate = self
        self.pickerView.dataSource = self

        view.backgroundColor = UIColor(white: 1, alpha: 0.5)

        view.addSubview(pickerView)
        pickerView.backgroundColor = .white
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        pickerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        pickerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true

        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.blue, for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmPressed(_:)), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor).isActive = true
        confirmButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor).isActive = true

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.blue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelPressed(_:)), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor).isActive = true
        cancelButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor).isActive = true
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = pickerData[row]
    }

    @objc func confirmPressed(_ sender: Any?) {
        guard let itemType = selectedItem else {
            return
        }
        delegate?.pick(itemType)
        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    @objc func cancelPressed(_ sender: Any?) {
        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
}
