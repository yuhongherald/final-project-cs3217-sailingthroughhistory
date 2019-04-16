//
//  ItemTableViewCell.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/19/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class ItemCollectionViewController: UIViewController, UICollectionViewDataSource,
UICollectionViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    private var itemTypes: [ItemType] = []
    private var selectedPort: Port?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
    }

    @IBAction func addPressed(_ sender: Any) {
        let alert = UIAlert(title: "Input item display name:", msg: nil, confirm: { _ in
            // TODO: add item type, add item parameter
        }, textPlaceHolder: "Input item name here")
        alert.present(in: self)
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
            let itemType = itemTypes[indexPath.item]

           /* if itemParam.isConsumable, let lifeText = castedCell.lifeField.text, let life = Int(lifeText) {
                itemParam.setHalfLife(to: life)
            }
            */
            if let buyPriceText = castedCell.buyField.text, let buyPrice = Int(buyPriceText) {
                port.setBuyValue(of: itemType, value: buyPrice)
            }

            if let sellPriceText = castedCell.sellField.text, let sellPrice = Int(sellPriceText) {
                port.setSellValue(of: itemType, value: sellPrice)
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
        self.itemTypes = port.getAllItemType()
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemTypes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "itemInfoCell", for: indexPath) as? ItemCollectionViewCell else {
                fatalError("Cell cannot be casted into ItemCollectionViewCell")
        }
        let itemType = itemTypes[indexPath.item]
        cell.label.text = itemType.rawValue

        guard let port = selectedPort else {
            return cell
        }

        if let sellPrice = port.getSellValue(of: itemType) {
            cell.sellField.text = String(sellPrice)
        }

        if let buyPrice = port.getBuyValue(of: itemType) {
            cell.buyField.text = String(buyPrice)
        }

        /// TODO: Refactor and move this
        /*if itemParam.isConsumable, let life = itemParam.getHalfLife() {
            cell.lifeField.isEnabled = true
            cell.lifeField.text = String(life)
        }

        if !itemParam.isConsumable {
            cell.lifeField.isEnabled = false
        }*/

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
