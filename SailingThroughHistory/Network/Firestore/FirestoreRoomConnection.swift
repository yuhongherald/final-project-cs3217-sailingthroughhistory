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
import FirebaseFunctions
import Foundation
import os

/// A room connection for a room with information stored on Firebase.
class FirebaseRoomConnection: RoomConnection {
    /// The time in seconds before an unresponsive device is removed from the room.
    static private let deadTime: TimeInterval = 60
    /// The device id of this device.
    private let deviceId: String
    /// The identifier of the room master device.
    private(set) var roomMasterId: String
    /// The number of players in this room on this device.
    private var numOfPlayers: Int
    /// The name of the room.
    private let roomName: String
    /// The timer used to check and update device heartbeat.
    private var heartbeatTimer: Timer?
    /// The callback to call when this device has been removed from the room.
    private var removalCallback: (() -> Void)?
    /// The listeners used to listen to network changes.
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

    /// Constructor for a connection to a room with the given name.
    ///
    /// - Parameter roomName: The name of the room.
    init(forRoom roomName: String) {
        self.roomName = roomName
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            fatalError("Device has no uuid")
        }

        self.deviceId = deviceId
        self.roomMasterId = ""
        self.numOfPlayers = 0
    }

    /// Subscibe to the removal of this device from the room.
    ///
    /// - Parameter removalCallback: Callback is called when this device has been removed from the room.
    private func subscribeRemoval(removalCallback: (() -> Void)?) {
        listeners.append(roomDocumentRef.addSnapshotListener { [weak self] (document, _) in
            guard let document = document, !document.exists else {
                return
            }

            document.reference.collection(FirestoreConstants.devicesCollectionName)
                .getDocuments(completion: { (snapshot, _) in
                guard let snapshot = snapshot else {
                    return
                }
                snapshot.documents.forEach { document in
                    self?.devicesCollectionRef.document(document.documentID).delete()
                }
            })

            document.reference.collection(FirestoreConstants.modelCollectionName)
                .getDocuments(completion: { (snapshot, _) in
                guard let snapshot = snapshot else {
                    return
                }
                snapshot.documents.forEach { document in
                    self?.modelCollectionRef.document(document.documentID).delete()
                }
            })

            document.reference.collection(FirestoreConstants.runTimeInfoCollectionName)
                .getDocuments(completion: { (snapshot, _) in
                guard let snapshot = snapshot else {
                    return
                }
                snapshot.documents.forEach { document in
                    self?.modelCollectionRef.document(document.documentID).delete()
                }
            })
        })

        listeners.append(devicesCollectionRef.document(deviceId).addSnapshotListener { [weak self] (document, _) in
            guard let document = document, !document.exists else {
                return
            }

            self?.playersCollectionRef.whereField(
                FirestoreConstants.playerDeviceKey, isEqualTo: document.documentID).getDocuments { (snapshot, _) in
                    guard let snapshot = snapshot else {
                        return
                    }
                    snapshot.documents.forEach { document in
                        document.reference.delete()
                    }
            }

            self?.disconnect()
            self?.removalCallback?()
        })
    }

    /// Get connection to the room with heartbeat scheduled and registers the device onto the room in the network.
    ///
    /// - Parameters:
    ///   - room: The room to join
    ///   - callback: The callback to be called once the connection has been established.
    static func getConnection(for room: FirestoreRoom,
                              completion callback: @escaping (RoomConnection?, Error?) -> Void) {
        let connection = FirebaseRoomConnection(forRoom: room.name)

        func postConnectionActions(error: Error?) {
            if let error = error {
                callback(nil, error)
            }
            connection.roomDocumentRef.getDocument { (querySnapshot, error) in
                guard let document = querySnapshot, error == nil else {
                    print("Failed to update master Id. Error: \(String(describing: error))")
                    return
                }
                connection.roomMasterId = document.get(FirestoreConstants.roomMasterKey) as? String ?? ""
                connection.postJoinActions(completion: callback)
            }
        }

        connection.roomDocumentRef.getDocument { (snapshot, error) in
            if let error = error {
                callback(nil, error)
                return
            }

            if let document = snapshot, document.exists {
                guard let started = document.get(FirestoreConstants.roomStartedKey) as? Bool else {
                    callback(nil, NetworkError.pullError(message: "Unable to read started."))
                    return
                }
                if !started {
                    // join as usual player
                    connection.devicesCollectionRef.document(connection.deviceId)
                        .setData([FirestoreConstants.numPlayersKey: connection.numOfPlayers]) { error in
                            postConnectionActions(error: error)
                        }
                } else {
                    callback(nil, NetworkError.pushError(message: "Game has already started."))
                }
            } else {
                connection.createRoom(completion: postConnectionActions)
            }
        }
    }

    func addPlayer() {
        let playerId = "\(getNewPlayerIndex())-" + self.deviceId
        self.playersCollectionRef
            .document(playerId)
            .setData([FirestoreConstants.playerDeviceKey: self.deviceId]) { [weak self] error in
                guard let self = self, error == nil else {
                    return
                }

                self.numOfPlayers += 1
                self.devicesCollectionRef.document(self.deviceId)
                    .updateData([FirestoreConstants.numPlayersKey: self.numOfPlayers])
        }
    }

    private func getNewPlayerIndex() -> Int {
        return self.numOfPlayers + 1
    }

    /// Create the room on the network.
    ///
    /// - Parameter completion: called when the room has been created, or failed to be created.
    private func createRoom(completion: @escaping (Error?) -> Void) {
        let currentTime = Date().timeIntervalSince1970
        let batch = Firestore.firestore().batch()
        let data: [String: Any] = [FirestoreConstants.roomMasterKey: self.deviceId,
                                   FirestoreConstants.roomStartedKey: false]
        batch.setData(data, forDocument: self.roomDocumentRef)
        batch.setData([FirestoreConstants.numPlayersKey: self.numOfPlayers,
                       FirestoreConstants.lastHeartBeatKey: currentTime],
                      forDocument: self.devicesCollectionRef.document(deviceId))
        batch.commit(completion: completion)
    }

    /// Carries out required actions after joining the room.
    ///
    /// - Parameter callback: called after actions have been carried out, either successfully or unsuccesfully.
    private func postJoinActions(completion callback: @escaping (RoomConnection?, Error?) -> Void) {
        self.sendAndCheckHeartBeat { [weak self] in
            self?.subscribeRemoval(removalCallback: nil)
        }
        self.devicesCollectionRef.document(self.deviceId)
            .updateData([FirestoreConstants.numPlayersKey: self.numOfPlayers])
        self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] _ in
            self?.sendAndCheckHeartBeat(completion: nil)
        })
        self.heartbeatTimer?.fire()

        callback(self, nil)
    }

    /// Sends the heartbeat for this device and then checks the heartbeat of devices on the room.
    ///
    /// - Parameter callback: called after the heartbeat has been sent to the network.
    private func sendAndCheckHeartBeat(completion callback: (() -> Void)?) {
        let currentTime = Date().timeIntervalSince1970
        devicesCollectionRef.document(deviceId)
            .setData([FirestoreConstants.lastHeartBeatKey: currentTime]) { _ in
                callback?()
                self.checkHeartBeat(currentTime: currentTime)
        }
    }

    /// Checks the heartbeat of devices on the network and removes any that have not been responsive for the predefined
    /// amount of time.
    ///
    /// - Parameter currentTime: The current time.
    private func checkHeartBeat(currentTime: TimeInterval) {
        devicesCollectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error reading device documents. \(error.localizedDescription)")
                return
            }

            guard let data = snapshot else {
                return
            }

            guard let deviceId = self?.deviceId else {
                return
            }

            var roomMasterPresent = false

            for document in data.documents {
                let deviceName = document.documentID
                guard let lastHeartBeat = document.get(FirestoreConstants.lastHeartBeatKey) as? TimeInterval else {
                    self?.removeDevice(withId: deviceName)
                    return
                }

                if currentTime - lastHeartBeat > FirebaseRoomConnection.deadTime {
                    self?.removeDevice(withId: deviceName)
                }

                if document.documentID == self?.roomMasterId {
                    roomMasterPresent = true
                }
            }

            if !roomMasterPresent {
                self?.removeDevice(withId: deviceId)
            }
        }
    }

    func removeDevice(withId deviceName: String) {
        self.devicesCollectionRef.document(deviceName).delete()
        self.playersCollectionRef.whereField(
            FirestoreConstants.playerDeviceKey, isEqualTo: deviceName).getDocuments { (snapshot, _) in
                guard let snapshot = snapshot else {
                    return
                }
                snapshot.documents.forEach {
                    $0.reference.delete()
                }
        }
        if deviceName == self.roomMasterId {
            FirebaseRoomConnection.deleteRoom(named: roomName)
        }
    }

    /// Deletes the room with the given name
    ///
    /// - Parameter name: The name of the room to delete.
    static func deleteRoom(named name: String) {
        Functions.functions()
            .httpsCallable("recursiveDelete")
            .call(["path": FirestoreConstants.roomCollection.document(name).path],
                  completion: { (_, error) in
                    if error != nil {
                        FirebaseRoomConnection.deleteWithoutFirebaseFunction(roomNamed: name)
                    }
        })
    }

    private static func deleteWithoutFirebaseFunction(roomNamed name: String) {
        let emptyConnection = FirebaseRoomConnection(forRoom: name)
        emptyConnection.devicesCollectionRef.getDocuments(completion: FirebaseRoomConnection.deleteDocuments)
        emptyConnection.playersCollectionRef.getDocuments(completion: FirebaseRoomConnection.deleteDocuments)
        emptyConnection.runTimeInfoCollectionRef.getDocuments(completion: FirebaseRoomConnection.deleteDocuments)
        emptyConnection.modelCollectionRef.getDocuments(completion: FirebaseRoomConnection.deleteDocuments)
        func deleteTurnAction(from turn: Int) {
            emptyConnection.turnActionsDocumentRef.collection(String(turn)).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    return
                }
                if snapshot.documents.count > 0 {
                    deleteTurnAction(from: turn + 1)
                }
                FirebaseRoomConnection.deleteDocuments(snapshot: snapshot, error: error)
            }
        }
        deleteTurnAction(from: 0)
        emptyConnection.roomDocumentRef.delete()
    }

    private static func deleteDocuments(snapshot: QuerySnapshot?, error: Error?) {
        guard let snapshot = snapshot else {
            return
        }

        for document in snapshot.documents {
            document.reference.delete()
        }
    }

    func startGame(initialState: GameState, background: Data, completion callback: @escaping (Error?) -> Void) throws {
        let reference = Storage.storage().reference().child(deviceId).child("background.png")
        let path = reference.fullPath
        reference
            .putData(background, metadata: StorageMetadata()) { [weak self] (_, error) in
                guard error == nil, let self = self else {
                    print(error ?? "Error starting game")
                    return
                }
                let batch = FirestoreConstants.firestore.batch()
                guard let data = try? FirestoreEncoder.init().encode(initialState) else {
                    print("Error encoding game state")
                    return
                }

                batch.setData(data, forDocument: self.modelCollectionRef.document(
                    FirestoreConstants.initialStateDocumentName))
                batch.updateData([FirestoreConstants.roomStartedKey: true,
                                  FirestoreConstants.backgroundUrlKey: path], forDocument: self.roomDocumentRef)

                batch.commit(completion: callback)
        }

    }

    func push(currentState: GameState, forTurn turn: Int, completion callback: @escaping (Error?) -> Void) throws {
        try push(currentState,
                 to: modelCollectionRef.document(String(turn)),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    func subscribeToMasterState(for turn: Int, callback: @escaping (GameState) -> Void) {
        listeners.append(modelCollectionRef.document(String(turn)).addSnapshotListener { (snapshot, error) in
            guard let data = snapshot?.data(),
                error == nil,
                let state = try? FirestoreDecoder.init().decode(GameState.self, from: data) else {
                    return
            }
            callback(state)
        })
    }

    func subscribeToActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        listeners.append(
            turnActionsDocumentRef.collection(String(turn)).addSnapshotListener { [weak self] (query, queryError) in
                self?.getTurnActions(from: query, error: queryError, callback: callback)
        })
    }

    /// Gets turn actions from a given query snapshot.
    ///
    /// - Parameters:
    ///   - query: The QuerySnapshot from Firestore.
    ///   - error: The error from the queyr.
    ///   - callback: The callback to call after the snapshot has been decoded.
    private func getTurnActions(from query: QuerySnapshot?, error: Error?,
                                callback: ([(String, [PlayerAction])], Error?) -> Void) {
        guard let snapshot = query else {
            callback([], NetworkError.pullError(message: "Snapshot is nil for turn actions"))
            return
        }

        if let queryError = error {
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
    }

    func getTurnActions(for turn: Int, callback: @escaping ([(String, [PlayerAction])], Error?) -> Void) {
        turnActionsDocumentRef.collection(String(turn)).getDocuments { [weak self] (snapshot, error) in
            self?.getTurnActions(from: snapshot, error: error, callback: callback)
        }
    }

    func subscribeToMembers(with callback: @escaping ([RoomMember]) -> Void) {
        listeners.append(playersCollectionRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let snapshot = snapshot, error == nil, let self = self else {
                return
            }

            var players = [RoomMember]()
            for document in snapshot.documents {
                let team = document.get(FirestoreConstants.playerTeamKey) as? String
                let playerName = document.get(FirestoreConstants.playerNameKey) as? String
                let isGameMaster = document.get(FirestoreConstants.isGmKey) as? Bool
                let playerID = document.documentID
                guard let deviceId = document.get(FirestoreConstants.playerDeviceKey) as? String else {
                    self.playersCollectionRef.document(document.documentID).delete()
                    continue
                }
                var member = RoomMember(identifier: playerID, playerName: playerName,
                                        teamName: team, deviceId: deviceId)
                member.isGameMaster = isGameMaster ?? false
                players.append(member)
            }

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

    func push(actions: [PlayerAction], fromPlayer player: GenericPlayer,
              forTurnNumbered turn: Int, completion callback: @escaping (Error?) -> Void) throws {
        /// Room doc -> runtimeinfo(col) -> TurnActions (doc) -> Turn1...Turn999 (col)
        try push(PlayerActionBatch(playerName: player.name, actions: actions),
                 to: turnActionsDocumentRef.collection(String(turn)).document(player.name),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    func set(teams: [Team]) {
        roomDocumentRef.updateData([FirestoreConstants.teamsKey: teams.map { $0.name }])
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

    func changeTeamName(for identifier: String, to teamName: String) throws {
        try verify(reference: teamName)
        playersCollectionRef.document(identifier).updateData([FirestoreConstants.playerTeamKey: teamName])
    }

    func changePlayerName(for identifier: String, to playerName: String) throws {
        try verify(reference: playerName)
        playersCollectionRef.document(identifier).updateData([FirestoreConstants.playerNameKey: playerName])
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

    func changeRemovalCallback(to callback: @escaping () -> Void) {
        self.removalCallback = {
            callback()
            self.listeners.forEach { $0.remove() }
        }
    }

    func verify(reference name: String) throws {
        try NetworkFactory.verify(name)
    }

    func disconnect() {
        self.heartbeatTimer?.invalidate()
        self.removeDevice(withId: deviceId)
    }
}
