//
//  Storage.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/21/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Storage {
    func save<T: Encodable>(_ data: T, with name: String) {
        let fileURL = getFullURL(from: name, ".pList")
        let imageURL = getFullURL(from: name, ".png")

        // Store level data
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(data) else {
            try? FileManager.default.removeItem(at: fileURL)
            fatalError("Couldn't encode data to JSON format.")
        }
        let savedJson = NSMutableData(data: jsonData)
        savedJson.write(to: fileURL, atomically: true)

        // Store level preview
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        guard (try? screenshot?.pngData()?.write(to: imageURL)) != nil else {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: imageURL)
            fatalError("Couldn't encode image to image format.")
        }
    }

    private func getFullURL(from fileName: String, _ extensionStr: String) -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        guard let documentDirectory = urls.first else {
            NSLog("DocumentDirectory is empty")
            return URL(fileReferenceLiteralResourceName: "")
        }

        let url = documentDirectory.appendingPathComponent(fileName + extensionStr)

        return url
    }
}
