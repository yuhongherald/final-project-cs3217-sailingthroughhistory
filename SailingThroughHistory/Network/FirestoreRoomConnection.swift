//
//  FirebaseConnection.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseFirestore
import CodableFirebase
import FirebaseStorage
import Foundation
import os

class FirebaseRoomConnection: RoomConnection {
    static private let deadTime: TimeInterval = 60
    private let deviceId: String
    private(set) var roomMasterId: String
    private var numOfPlayers: Int
    private let roomName: String
    private var heartbeatTimer: Timer?
    private var listeners = [ListenerRegistration]()
    private var roomDocumentRef: DocumentReference {
        return FirestoreConstants.roomCollection.document(roomName)
    }

    private var modelCollectionRef: CollectionReference {
        return roomDocumentRef.collection(FirestoreConstants.modelCollectionName)
    }

    private var runTimeInfoCollectionRef: CollectionReference {
        return roomDocumentRef.collection(FirestoreConstants.runTimeInfoCollectionName)
    }

    private var turnActionsDocumentRef: DocumentReference {
        return runTimeInfoCollectionRef.document(FirestoreConstants.turnActionsDocumentName)
    }

    private var devicesCollectionRef: CollectionReference {
        return roomDocumentRef.collection(FirestoreConstants.devicesCollectionName)
    }

    private var playersCollectionRef: CollectionReference {
        return roomDocumentRef.collection(FirestoreConstants.playersCollectionName)
    }

    init(forRoom roomName: String) {
        self.roomName = roomName
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError("Device has no uuid")
        }

        self.deviceId = deviceId
        self.roomMasterId = ""
        self.numOfPlayers = 0
    }

    private func subscribeRemoval(removalCallback: @escaping () -> Void) {
        listeners.append(roomDocumentRef.addSnapshotListener { (document, _) in
            if let document = document {
                if !document.exists {
                    removalCallback()
                }
            }
        })

        listeners.append(devicesCollectionRef.document(deviceId).addSnapshotListener { (document, _) in
            guard let document = document, !document.exists else {
                return
            }

            self.devicesCollectionRef.document(document.documentID).collection(FirestoreConstants.playersCollectionName).getDocuments(completion: { (snapshot, _) in
                guard let snapshot = snapshot else {
                    return
                }
                snapshot.documents.forEach { document in
                    self.playersCollectionRef.document(document.documentID).delete()
                }
            })

            removalCallback()
        })
    }

    static func getConnection(for room: FirestoreRoom, removed removedCallback: @escaping () -> Void,
                              completion callback: @escaping (RoomConnection?, Error?) -> Void) {
        let connection = FirebaseRoomConnection(forRoom: room.name)

        func postConnectionActions(error: Error?) {
            if let error = error {
                callback(nil, error)
            }

            connection.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                connection.sendAndCheckHeartBeat()
            })
            connection.heartbeatTimer?.fire()
            connection.subscribeRemoval(removalCallback: removedCallback)
            connection.roomDocumentRef.getDocument { (querySnapshot, error) in
                guard let document = querySnapshot, error == nil else {
                    print("Failed to update master Id. Error: \(String(describing: error))")
                    return
                }
                connection.roomMasterId = document.get(FirestoreConstants.roomMasterKey) as? String ?? ""
            }
            callback(connection, error)
        }

        connection.roomDocumentRef.getDocument { (snapshot, error) in
            if let error = error {
                callback(nil, error)
                return
            }

            if let document = snapshot, document.exists {
                connection.devicesCollectionRef.document(connection.deviceId).setData([FirestoreConstants.numPlayersKey: connection.numOfPlayers])
                connection.joinRoom(completion: postConnectionActions)
            } else {
                connection.createRoom(completion: postConnectionActions)
            }
        }
    }

    func join(removed removedCallback: @escaping () -> Void,
              completion callback: @escaping (RoomConnection?, Error?) -> Void) {
        joinRoom(completion: self.postJoinActions(removed: removedCallback, completion: callback))
    }

    func getNewPlayerIndex() -> Int {
        self.devicesCollectionRef.document(deviceId).getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            }

            if let document = snapshot, document.exists, let num = document.get(FirestoreConstants.numPlayersKey) as? Int {
                self.numOfPlayers = num
            } else {
                self.devicesCollectionRef.document(self.deviceId).setData([FirestoreConstants.numPlayersKey: self.numOfPlayers])
            }
        }
        return self.numOfPlayers + 1
    }

    private func joinRoom(completion: @escaping (Error?) -> Void) {
        let playerId = "No. \(getNewPlayerIndex()) " + self.deviceId
        self.playersCollectionRef.document(playerId).setData([FirestoreConstants.playerDeviceKey: self.deviceId]) { error in
            completion(error)
        }
    }

    private func createRoom(completion: @escaping (Error?) -> Void) {
        let batch = Firestore.firestore().batch()
        let data: [String: Any] = [FirestoreConstants.roomMasterKey: self.deviceId,
                                   FirestoreConstants.roomStartedKey: false]
        batch.setData(data, forDocument: self.roomDocumentRef)
        self.roomDocumentRef.setData([FirestoreConstants.roomMasterKey: self.deviceId])
        self.devicesCollectionRef.document(deviceId).setData([FirestoreConstants.numPlayersKey: self.numOfPlayers])
        batch.commit(completion: completion)
    }

    private func postJoinActions(removed removedCallback: @escaping () -> Void,
                        completion callback: @escaping (RoomConnection?, Error?) -> Void) -> (Error?) -> Void {
       let completion: (Error?) -> Void = { error in
            if let error = error {
                callback(nil, error)
            }
            self.numOfPlayers += 1
            self.subscribeRemoval(removalCallback: removedCallback)
            self.devicesCollectionRef.document(self.deviceId).updateData([FirestoreConstants.numPlayersKey: self.numOfPlayers])
            self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                self.sendAndCheckHeartBeat()
            })
            self.heartbeatTimer?.fire()

            callback(self, error)
        }
        return completion
    }

    private func sendAndCheckHeartBeat() {
        let currentTime = Date().timeIntervalSince1970
        devicesCollectionRef.document(deviceId)
            .updateData([FirestoreConstants.lastHeartBeatKey: currentTime])
        devicesCollectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error reading device documents. \(error.localizedDescription)")
                return
            }

            guard let data = snapshot else {
                return
            }

            for document in data.documents {
                guard let lastHeartBeat = document.get(FirestoreConstants.lastHeartBeatKey) as? TimeInterval else {
                    print("Error reading last heartbeat for \(document.documentID)")
                    document.reference.delete()
                    return
                }

                if currentTime - lastHeartBeat > FirebaseRoomConnection.deadTime {
                    let deviceName = document.documentID
                    /// Remove player
                    self?.devicesCollectionRef.document(deviceName).delete()

                    if deviceName == self?.roomMasterId {
                        self?.roomDocumentRef.delete()
                    }
                }
            }
        }
    }

    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws {
        let reference = Storage.storage().reference().child(deviceId).child("background.png")
        let path = reference.fullPath
        reference
            .putData(background, metadata: StorageMetadata()) { [weak self] (metadata, error) in
            guard error == nil, let self = self else {
                return
            }
            let batch = FirestoreConstants.firestore.batch()
            guard let data = try? FirestoreEncoder.init().encode(initialState) else {
                return
            }

            batch.setData(data, forDocument: self.modelCollectionRef.document(FirestoreConstants.initialStateDocumentName))
            batch.updateData([FirestoreConstants.roomStartedKey: true,
                              FirestoreConstants.backgroundUrlKey: path], forDocument: self.roomDocumentRef)

            batch.commit(completion: callback)
        }

    }

    private func push(initialState: GameState, completion callback: @escaping (Error?) -> Void) throws {
        try push(initialState,
                 to: modelCollectionRef.document(FirestoreConstants.initialStateDocumentName),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    func push(currentState: GameState, completion callback: @escaping (Error?) -> Void) throws {
        try push(currentState,
                 to: modelCollectionRef.document(FirestoreConstants.currentStateDocumentName),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        listeners.append(turnActionsDocumentRef.collection(String(turn)).addSnapshotListener { (query, queryError) in
            guard let snapshot = query else {
                callback([], NetworkError.pullError(message: "Snapshot is nil for turn actions"))
                return
            }

            if let queryError = queryError {
                callback([], NetworkError.pullError(message: queryError.localizedDescription))
                return
            }

            do {
                let actions = try snapshot.documents.map {
                    ($0.documentID, try FirebaseDecoder.init().decode(PlayerActionBatch.self, from: $0.data()).actions)
                    }
                callback(actions, nil)
            } catch {
                callback([],
                         NetworkError.pullError(message: "Error when decoding: \(error.localizedDescription)"))
            }
        })
    }

    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void) {
        listeners.append(playersCollectionRef.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                return
            }

            let players = snapshot.documents.map({ (document) -> RoomMember in
                let team = document.get(FirestoreConstants.playerTeamKey) as? String
                let player = document.documentID
                guard let deviceId = document.get(FirestoreConstants.playerDeviceKey) as? String else {
                    // Remove invalid player
                    fatalError("Invalid player doesn't have device id.")
                }

                return RoomMember(playerName: player, teamName: team, deviceId: deviceId)
            })

            print(players.count)
            callback(players)
        })
    }

    private func push<T: Codable>(_ codable: T, to docRef: DocumentReference,
                                  encodeErrorMsg: String,
                                  completion callback: @escaping (Error?) -> Void) throws {
        guard let encoded = try? FirestoreEncoder().encode(codable) else {
            throw NetworkError.encodeError(message: encodeErrorMsg)
        }

        docRef.setData(encoded, completion: callback)
    }

    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer, forTurnNumbered turn: Int, completion callback: @escaping (Error?) -> ()) throws {
        /// TODO: Change collection
        /// Room doc -> runtimeinfo(col) -> TurnActions (doc) -> Turn1...Turn999 (col)
        try push(PlayerActionBatch(playerName: player.name, actions: actions),
                 to: turnActionsDocumentRef.collection(String(turn)).document(player.name),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    func checkTurnEnd(actions: [Map], forTurnNumbered turn: Int) throws {

    }

    func set(teams: [Team]) {
        roomDocumentRef.setData([FirestoreConstants.teamsKey: teams.map { $0.name }])
    }

    func subscibeToTeamNames(with callback: @escaping ([String]) -> Void) {
        self.listeners.append(roomDocumentRef.addSnapshotListener({ (document, error) in
            guard let document = document, error == nil,
                let teamNames = document.get(FirestoreConstants.teamsKey) as? [String] else {
                return
            }

            callback(teamNames)
        }))
    }

    func changeTeamName(for identifier: String, to teamName: String) {
        playersCollectionRef.document(identifier).updateData([FirestoreConstants.playerTeamKey: teamName])
    }

    func remove(player identifier: String) {
        self.numOfPlayers -= 1
        self.numOfPlayers = self.numOfPlayers >= 0 ? self.numOfPlayers : 0
        devicesCollectionRef.document(self.deviceId).updateData([FirestoreConstants.numPlayersKey: self.numOfPlayers])
        playersCollectionRef.document(identifier).delete()
    }

    func subscribeToStart(with callback: @escaping (GameState, Data) -> Void) {
        self.listeners.append(modelCollectionRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                return
            }

            guard let document = snapshot.documents
                .filter({ $0.documentID == FirestoreConstants.initialStateDocumentName})
                .first else {
                    return
            }

            guard let initialState = try? FirestoreDecoder.init().decode(GameState.self, from: document.data()) else {
                print("Error decoding game state")
                return
            }
            self?.roomDocumentRef.getDocument { (snapshot, error) in
                guard let snapshot = snapshot, error == nil else {
                    return
                }
                guard let url = snapshot.get(FirestoreConstants.backgroundUrlKey) as? String else {
                    return
                }
                Storage.storage().reference(withPath: url)
                    .getData(maxSize: FirestoreConstants.maxImageSize) { (data, error) in
                        guard let data = data, error == nil else {
                            return
                        }
                        callback(initialState, data)
                    }
            }
        })
    }

    deinit {
        self.heartbeatTimer?.invalidate()
        self.listeners.forEach { $0.remove() }
    }
}
