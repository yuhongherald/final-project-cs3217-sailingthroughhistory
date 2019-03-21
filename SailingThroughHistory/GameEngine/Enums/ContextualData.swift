//
//  ContextualData.swift
//  SailingThroughHistory
//
//  Created by Herald on 20/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

enum ContextualData {
    case message(message: String)
    // can add another category with formatted data fields if needed
    case image(image: String)
    case animated(images: [String])
    case none
}
