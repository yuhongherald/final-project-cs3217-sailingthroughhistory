//
//  FirestoreConstants.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseFirestore

enum FirestoreConstants {
    static let maxImageSize: Int64 = 104857600 // 100MB
    static let firestore = Firestore.firestore()
    static let rooms = firestore.collection("Rooms")
    static let roomCollectionName = "Rooms"
    static let roomCollection = firestore.collection(roomCollectionName)
    static let modelCollectionName = "Model"
    static let initialStateDocumentName = "Initial State"
    static let currentStateDocumentName = "Current State"
    static let runTimeInfoCollectionName = "Runtime Info"
    static let turnActionsDocumentName = "TurnActions"
    static let errorCategory = "Firebase"
    static let numPlayersKey = "NumPlayers"
    static let playersCollectionName = "Players"
    static let devicesCollectionName = "Devices"
    static let lastHeartBeatKey = "LastHeartBeat"
    static let pushStateErrorMsg: StaticString = "Failed to push state"
    static let encodeStateErrorMsg = "Failed to encode state"
    static let pullErrorMsg = "Failed to pull document."
    static let roomMasterKey = "RoomMaster"
    static let roomStartedKey = "started"
    static let playerTeamKey = "Team"
    static let playerDeviceKey = "Device"
    static let teamsKey = "Teams"
    static let backgroundUrlKey = "backgroundUrl"
    static let isGmKey = "isGm"
}
