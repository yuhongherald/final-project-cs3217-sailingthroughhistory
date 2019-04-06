//
//  GallaryViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/22/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

protocol GalleryViewDelegateProtocol: class {
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
        // Do any additional setup after loading the view.
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
            let alert = UIAlert(errorMsg: "Level broken. Level data is deleted.", msg: nil)
            alert.present(in: self)
            return
        }
        self.dismiss(animated: true, completion: {
            self.collectionView.removeFromSuperview()
        })
        selectedCallback?(gameParameter)
    }
}
