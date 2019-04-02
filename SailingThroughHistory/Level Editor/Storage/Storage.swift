//
//  Storage.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/21/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Storage {
    func save<T: Encodable>(_ data: T, _ background: UIImage?, preview screenShot: UIImage?, with name: String) {
        let backgroundName = name + "background"
        let fileURL = getFullURL(from: name, ".pList")
        let backgroundURL = getFullURL(from: backgroundName, ".png")
        let previewURL = getFullURL(from: name, ".png")

        // Store level data
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        guard let jsonData = try? jsonEncoder.encode(data),
              (try? background?.pngData()?.write(to: backgroundURL)) != nil,
            (try? screenShot?.pngData()?.write(to: previewURL)) != nil else {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: backgroundURL)
            try? FileManager.default.removeItem(at: previewURL)

            fatalError("Couldn't encode data to JSON format.")
        }
        let savedJson = NSMutableData(data: jsonData)
        savedJson.write(to: fileURL, atomically: true)
    }

    func readLevelData<T: Codable>(_ fileName: String) -> T? {
        let url = getFullURL(from: fileName, ".pList")
        guard let data = try? Data(contentsOf: url) else {
            fatalError("\(url) Data load failed")
        }

        guard let levelData = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Decode failed")
        }
        return levelData
    }

    func readImage(_ fileName: String) -> UIImage? {
        let url = getFullURL(from: fileName, ".png")

        guard let imageData = try? Data(contentsOf: url) else {
            return nil
        }
        guard let image = UIImage(data: imageData) else {
            return nil
        }
        return image
    }

    /// Return all level names in the document directory without any extension.
    func getAllRecords() -> [String] {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // Get the URL for a file in the Documents Directory
        guard let documentDirectory = urls.first else {
            return [String]()
        }

        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: documentDirectory, includingPropertiesForKeys: [], options: .skipsHiddenFiles) else {
                return [String]()
        }

        return fileURLs.filter { $0.pathExtension == "pList" }
            .compactMap { $0.lastPathComponent }
            .map { $0.replacingOccurrences(of: ".pList", with: "") }
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
