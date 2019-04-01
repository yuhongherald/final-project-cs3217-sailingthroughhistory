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
    private var storage = Storage()
    private var levelNames: [String] = []
    weak var delegate: GalleryViewDelegateProtocol?
    var selectedCallback: ((GameParameter) -> Void)?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        levelNames = storage.getAllRecords()
        // Do any additional setup after loading the view.
    }
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmPressed(_ sender: Any) {
        //TODO: move load here
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
        /// TODO: Solve memory issue and then uncomment
        /*DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let image = self?.storage.readImage(levelName)
            DispatchQueue.main.async {
                cell.previewImage.image = image
            }
        }*/

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let levelName = levelNames[indexPath.item]
        guard let gameParameter: GameParameter = storage.readLevelData(levelName) else {
            // TODO: raise alert and delete the data
            //fatalError("level data broken")
            return
        }

        selectedCallback?(gameParameter)
    }
}
