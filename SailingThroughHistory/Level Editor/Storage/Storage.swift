//
//  Storage.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/21/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class Storage {
    func verify(name: String) throws {
        guard name != "" else {
            throw StorageError.invalidName(message: "Empty level name.")
        }

        guard name.count < 255 else {
            throw StorageError.invalidName(message: "Level name is too long.")
        }

        guard !name.contains("/") else {
            throw StorageError.invalidName(message: "Level name contains invalid symbol.")
        }

        guard isLevelExist(name) else {
            throw StorageError.fileExisted(message: "Level already exists.")
        }
    }

    func save<T: Encodable>(_ data: T, _ background: UIImage?, preview screenShot: UIImage?, with name: String) -> Bool {
        let backgroundName = name + Default.Suffix.background
        let fileURL = getFullURL(from: name, ".pList")
        let backgroundURL = getFullURL(from: backgroundName, ".png")
        let previewURL = getFullURL(from: name, ".png")

        // Store level data
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        guard let jsonData = try? jsonEncoder.encode(data),
              (try? background?.pngData()?.write(to: backgroundURL)) != nil,
            (try? screenShot?.pngData()?.write(to: previewURL)) != nil else {
            deleteLevel(name)
            NSLog("Couldn't encode data to JSON format.")
            return false
        }
        let savedJson = NSMutableData(data: jsonData)
        savedJson.write(to: fileURL, atomically: true)
        return true
    }

    func readLevelData<T: Codable>(_ fileName: String) -> T? {
        let url = getFullURL(from: fileName, ".pList")
        guard let data = try? Data(contentsOf: url) else {
            NSLog("Reading level \(fileName) not exist.")
            return nil
        }

        guard let levelData = try? JSONDecoder().decode(T.self, from: data) else {
            NSLog("Decoding level failed. ")
            return nil
        }
        return levelData
    }

    func readImage(_ fileName: String) -> UIImage? {
        let url = getFullURL(from: fileName, ".png")

        guard let imageData = try? Data(contentsOf: url) else {
            NSLog("Reading image \(fileName) not exist.")
            return nil
        }
        guard let image = UIImage(data: imageData) else {
            NSLog("Initializing image from data failed. ")
            return nil
        }
        return image
    }

    func deleteLevel(_ name: String) {
        let backgroundName = name + Default.Suffix.background
        let fileURL = getFullURL(from: name, ".pList")
        let backgroundURL = getFullURL(from: backgroundName, ".png")
        let previewURL = getFullURL(from: name, ".png")

        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: backgroundURL)
        try? FileManager.default.removeItem(at: previewURL)
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
            .filter { self.isLevelExist($0) }
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

    func isLevelExist(_ name: String) -> Bool {
        let fileURL = getFullURL(from: name, ".pList")
        let backgroundURL = getFullURL(from: name + Default.Suffix.background, ".png")
        let previewURL = getFullURL(from: name, ".png")
        let fileManager = FileManager.default

        return fileManager.fileExists(atPath: fileURL.path)
            && fileManager.fileExists(atPath: backgroundURL.path)
            && fileManager.fileExists(atPath: previewURL.path)
    }
}

enum StorageError: Error {
    case invalidName(message: String)
    case fileExisted(message: String)

    func getMessage() -> String {
        switch self {
        case .invalidName(message: let message):
            return message
        case .fileExisted(message: let message):
            return message
        }
    }
}
