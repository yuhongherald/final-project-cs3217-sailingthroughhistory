//
//  ItemTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ItemPickerViewController: UIViewController, UICollectionViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private var itemParameters: [ItemParameter] = []
    private var selectedPort: Port?

    @IBAction func confirmPressed(_ sender: Any?) {
        guard let port = selectedPort else {
            return
        }

        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell),
            let castedCell = cell as? ItemCollectionViewCell else {
                continue
            }
            let itemParam = itemParameters[indexPath.item]

            if let buyPriceText = castedCell.buyField.text, let buyPrice = Int(buyPriceText) {
                itemParam.setBuyValue(at: port, value: buyPrice)
            }

            if let sellPriceText = castedCell.sellField.text, let sellPrice = Int(sellPriceText) {
                itemParam.setSellValue(at: port, value: sellPrice)
            }
        }

        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelPressed(_ sender: Any?) {
        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    func set(port: Port, itemParameters: Set<ItemParameter>) {
        self.selectedPort = port
        self.itemParameters = Array(itemParameters)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemParameters.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "itemInfoCell", for: indexPath) as? ItemCollectionViewCell else {
                fatalError("Cell cannot be casted into ItemCollectionViewCell")
        }
        let itemParam = itemParameters[indexPath.item]
        cell.label.text = itemParam.displayName

        guard let port = selectedPort else {
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
