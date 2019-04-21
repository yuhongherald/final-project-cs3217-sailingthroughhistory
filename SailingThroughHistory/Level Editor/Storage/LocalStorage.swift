//
//  Storage.swift
//  SailingThroughHistory
//
//  Created by ysq on 3/21/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import UIKit

class LocalStorage {
    /// Check the validation of level name.
    /// - Parameters:
    ///   - name: the proposed level name.
    func verify(name: String) throws {
        guard !name.isEmpty else {
            throw StorageError.invalidName(message: "Empty level name.")
        }

        guard name.count < 255 else {
            throw StorageError.invalidName(message: "Level name is too long.")
        }

        guard name.range(of: "[^a-zA-Z0-9-]", options: .regularExpression) == nil else {
            throw StorageError.invalidName(message:
                "Room name contains invalid symbol. Only alphanumeric and - is allowed.")
        }
    }

    /// Attempt to encode level data into json file. A complete level data set
    /// should contains data, background image and preview image.
    /// On failure, all the related level data should be deleted.
    /// - Parameters:
    ///   - data: encodable data to be save into a JSON file
    ///   - background: the background image to be saved
    ///   - screenShot: the preview of level
    ///   - name: proposed level name
    func save<T: Encodable>(_ data: T, _ background: UIImage,
                            preview screenShot: UIImage, with name: String, replace: Bool = false) throws -> Bool {
        try verify(name: name)
        guard replace || !isLevelExist(name) else {
            throw StorageError.fileExisted(message: "Level already exists.")
        }

        let backgroundName = name + Default.Suffix.background
        let fileURL = getFullURL(from: name, ".pList")
        let backgroundURL = getFullURL(from: backgroundName, ".png")
        let previewURL = getFullURL(from: name, ".png")

        // Store level data
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        guard let jsonData = try? jsonEncoder.encode(data),
              (try? background.pngData()?.write(to: backgroundURL)) != nil,
            (try? screenShot.pngData()?.write(to: previewURL)) != nil else {
            deleteLevel(name)
            NSLog("Couldn't encode data to JSON format.")
            return false
        }
        let savedJson = NSMutableData(data: jsonData)
        savedJson.write(to: fileURL, atomically: true)
        return true
    }

    /// Attempt to decode level data.
    /// On failure return nil and delete all related data. Log the failure information.
    /// - Parameters:
    ///   - fileName: name of the level to be decoded
    func readLevelData<T: Codable>(_ fileName: String) -> T? {
        let url = getFullURL(from: fileName, ".pList")
        guard let data = try? Data(contentsOf: url) else {
            deleteLevel(fileName)
            NSLog("Reading level \(fileName) not exist.")
            return nil
        }

        guard let levelData = try? JSONDecoder().decode(T.self, from: data) else {
            deleteLevel(fileName)
            NSLog("Decoding level failed. ")
            return nil
        }
        return levelData
    }

    /// Attempt to decode and init UIImage from image data.
    /// On failure return nil and delete all related data. Log the failure information.
    /// - Parameters:
    ///   - fileName: name of the image to be decoded
    /// - Returns:
    ///   UIImage constructed from the decoded data.
    func readImage(_ fileName: String) -> UIImage? {
        guard let imageData = readImageData(fileName) else {
            deleteLevel(fileName)
            NSLog("Reading image \(fileName) not exist.")
            return nil
        }
        guard let image = UIImage(data: imageData) else {
            deleteLevel(fileName)
            NSLog("Initializing image from data failed. ")
            return nil
        }
        return image
    }

    /// Attempt to decode image data.
    /// On failure return nil and delete all related data. Log the failure information.
    /// - Parameters:
    ///   - fileName: name of the image to be decoded
    func readImageData(_ fileName: String) -> Data? {
        let url = getFullURL(from: fileName, ".png")

        guard let imageData = try? Data(contentsOf: url) else {
            deleteLevel(fileName)
            return nil
        }

        return imageData
    }

    /// Delete all files related to a level, including JSON file, background image and preview image.
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

    private func isLevelExist(_ name: String) -> Bool {
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
