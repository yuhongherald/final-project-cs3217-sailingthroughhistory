//
//  EdiePanelViewController.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/18/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit
protocol EditPanelDelegateProtocol {
    func clicked(_ select: EditableObject)
}
class EditPanelViewController: UIViewController {
    var delegate:EditPanelDelegateProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func addMapPressed(_ sender: Any) {
        // TODO: add external image
    }

    @IBAction func addSeaPressed(_ sender: Any) {
        delegate?.clicked(.sea)
    }

    @IBAction func addPathPressed(_ sender: Any) {
        delegate?.clicked(.path)
    }

    @IBAction func addPortPressed(_ sender: Any) {
        delegate?.clicked(.port)
    }

    @IBAction func removePressed(_ sender: Any) {
        delegate?.clicked(.erase)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
