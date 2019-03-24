//
//  ItemTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ItemCollectionViewController: UIViewController, UICollectionViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private var itemParameters: [ItemParameter] = []
    private var selectedPort: Port?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

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
                port.setBuyValue(of: itemParam.itemType, value: buyPrice)
            }

            if let sellPriceText = castedCell.sellField.text, let sellPrice = Int(sellPriceText) {
                port.setSellValue(of: itemParam.itemType, value: sellPrice)
            }
        }

        view.removeFromSuperview()
        self.removeFromParent()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelPressed(_ sender: Any?) {
        view.removeFromSuperview()
        self.removeFromParent()
        self.dismiss(animated: true, completion: nil)
    }

    func initWith(port: Port) {
        self.selectedPort = port
        self.itemParameters = port.getAllItemParameters()
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

        if let sellPrice = port.getSellValue(of: itemParam.itemType) {
            cell.sellField.text = String(sellPrice)
        }

        if let buyPrice = port.getBuyValue(of: itemParam.itemType) {
            cell.buyField.text = String(buyPrice)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind, withReuseIdentifier: "itemCollectionHeaderView",
                    for: indexPath)
        default:
            assert(false, "Invalid element type")
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
}
