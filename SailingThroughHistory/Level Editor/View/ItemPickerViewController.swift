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

class ItemPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var items = ItemType.getAll()

    @IBAction func confirmPressed(_ sender: Any?) {
        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func cancelPressed(_ sender: Any?) {
        view.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "itemInfoCell", for: indexPath) as? ItemCollectionViewCell else {
                fatalError("Cell cannot be casted into ItemCollectionViewCell")
        }
        cell.label.text = items[indexPath.item].rawValue
        // TODO: show price
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
}
