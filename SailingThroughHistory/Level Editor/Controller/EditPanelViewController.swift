//
//  EdiePanelViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/18/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

/// Protocol for delegate of edit panel, to help communication between edit panel
/// and LevelEditorViewController.
protocol EditPanelDelegateProtocol: class {
    /// The game parameter that is associated with the panel.
    var gameParameter: GameParameter { get }
    /// Send the button information that is clicked back to the parent controller.
    func clicked(_ select: EditMode)
    /// Change map background to image.
    func addMapBackground(_ image: UIImage)
}

class EditPanelViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: EditPanelDelegateProtocol?

    override var prefersStatusBarHidden: Bool {
        return true
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

    @IBAction func addWeatherPressed(_ sender: Any) {
        delegate?.clicked(.weather)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "playerTable")
            as? DetailEditTableViewController else {
                fatalError("Controller is not found or cannot be casted into DetailEditTableViewController.")
        }

        guard let unwrappedGame = self.delegate?.gameParameter else {
            fatalError("EditPanelDelegateProtocol not set.")
        }
        controller.initWith(game: unwrappedGame)

        self.show(controller, sender: nil)
    }

    @IBAction func editItemPressed(_ sender: Any) {
        self.delegate?.clicked(.item)
    }

    @IBAction func removePressed(_ sender: Any) {
        delegate?.clicked(.erase)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            delegate?.addMapBackground(image)
        }

        self.dismiss(animated: true, completion: nil)
    }
}
