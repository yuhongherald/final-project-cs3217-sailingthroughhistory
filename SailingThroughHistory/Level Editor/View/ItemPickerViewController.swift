//
//  ItemTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ItemPickerViewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private var items = ItemType.getAll()
    private var itemParameters = [ItemParameter]()
    private var selectedPort: Port?

    override func viewDidLoad() {
        items.forEach {
            itemParameters.append(ItemParameter(itemType: $0, displayName: $0.rawValue, weight: -1, isConsumable: true))
        }
    }

    @IBAction func confirmPressed(_ sender: Any?) {
        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelPressed(_ sender: Any?) {
        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    func setPort(_ port: Port) {
        selectedPort = port
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "itemInfoCell", for: indexPath) as? ItemCollectionViewCell else {
                fatalError("Cell cannot be casted into ItemCollectionViewCell")
        }
        let itemParam = itemParameters[indexPath.item]
        cell.label.text = itemParam.displayName
        cell.item = itemParam
        cell.port = selectedPort

        guard let port = selectedPort else {
            print("select port empty!")
            return cell
        }

        if let sellPrice = itemParam.getSellValue(at: port) {
            cell.sellField.text = String(sellPrice)
        }

        if let buyPrice = itemParam.getBuyValue(at: port) {
            cell.buyField.text = String(buyPrice)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        var view: UIView = textField
        repeat { view = view.superview! } while !(view is UICollectionViewCell)

        guard let tag = TextFieldTag.init(rawValue: textField.tag),
            let selectedPort = selectedPort,
            let cell = view as? ItemCollectionViewCell,
            let indexPath = self.collectionView.indexPath(for:cell) else {
            return
        }

        let item = itemParameters[indexPath.item]

        guard let text = textField.text else {
            return
        }

        guard let price = Int(text) else {
            return
        }

        switch tag {
        case .sellField:
            item.setSellValue(at: selectedPort, value: price)
        case .buyField:
            item.setBuyValue(at: selectedPort, value: price)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
