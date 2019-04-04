//
//  UIView + ScreenShot.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/22/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

extension UIView {
    var screenShot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)

        drawHierarchy(in: self.frame, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
