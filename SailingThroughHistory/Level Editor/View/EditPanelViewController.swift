//
//  EdiePanelViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/18/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit
protocol EditPanelDelegateProtocol {
    func clicked(_ select: EditMode)
    func addMapBackground(_ image: UIImage)
}

class EditPanelViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate: EditPanelDelegateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func addMapPressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary

        imagePicker.allowsEditing = false

        self.present(imagePicker, animated:
            true)
    }

    @IBAction func addPiratePressed(_ sender: Any) {
        delegate?.clicked(.pirate)
    }

    @IBAction func addPortPressed(_ sender: Any) {
        delegate?.clicked(.port)
    }

    @IBAction func addSeaPressed(_ sender: Any) {
        delegate?.clicked(.sea)
    }

    @IBAction func addPathPressed(_ sender: Any) {
        delegate?.clicked(.path)
    }

    @IBAction func editParamPressed(_ sender: Any) {
        // TODO: set player param
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "playerTable")
            as? DetailEditTableViewController else {
                fatalError("Controller is not found or cannot be casted into DetailEditTableViewController.")
        }

        self.show(controller, sender: nil)

    }

    @IBAction func editItemPressed(_ sender: Any) {
        self.delegate?.clicked(.item)
    }

    @IBAction func editEventsPressed(_ sender: Any) {
        // TODO: set events condition
    }

    @IBAction func removePressed(_ sender: Any) {
        delegate?.clicked(.erase)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            delegate?.addMapBackground(image)
        }

        self.dismiss(animated: true, completion: nil)
    }
}
