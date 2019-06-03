//
//  GallaryViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/22/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// Protocol for delegate of gallery.
protocol GalleryViewDelegateProtocol: class {
    /// Load decoded gameParameter.
    func load(_ gameParameter: GameParameter)
}

class GalleryViewController: UIViewController {
    private var storage = LocalStorage()
    private var levelNames: [String] = []
    weak var delegate: GalleryViewDelegateProtocol?
    var selectedCallback: ((GameParameter) -> Void)?
    @IBOutlet weak var collectionView: UICollectionView!

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        levelNames = storage.getAllRecords()
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.collectionView.removeFromSuperview()
        })
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levelNames.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "record", for: indexPath)
            as? GalleryCollectionViewCell else {
                fatalError("Cell cannot be casted into GallaryCollectionViewCell")
        }
        let levelName = levelNames[indexPath.item]
        cell.label.text = levelName

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(remove(_:)))
        cell.addGestureRecognizer(gesture)

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let image = self?.storage.readImage(levelName)
            DispatchQueue.main.async {
                cell.previewImage.image = image
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let levelName = levelNames[indexPath.item]
        guard let gameParameter: GameParameter = storage.readLevelData(levelName) else {
            let alert = ControllerUtils.getGenericAlert(titled: "Level broken. Level data is deleted.", withMsg: "")
            self.present(alert, animated: true, completion: nil)
            levelNames = storage.getAllRecords()
            self.collectionView.reloadData()
            return
        }
        self.dismiss(animated: true, completion: {
            self.collectionView.removeFromSuperview()
        })
        selectedCallback?(gameParameter)
    }

    @objc func remove(_ sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? GalleryCollectionViewCell, let name = cell.label.text else {
            return
        }
        let alert = ControllerUtils.getConfirmationAlert(title: "Are you sure to delete \(name)?", desc: "", okAction: {
            self.storage.deleteLevel(name)
            self.levelNames = self.storage.getAllRecords()
            self.collectionView.reloadData()
        }, cancelAction: nil)
        self.present(alert, animated: true, completion: nil)
    }
}
