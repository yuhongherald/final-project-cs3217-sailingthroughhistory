//
//  FirebaseConnection.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseFirestore
import CodableFirebase
import Foundation
import os

class FirebaseRoomConnection: RoomConnection {

    private let deviceId: String
    private(set) var roomMasterId: String
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
    }

    private func subscribeRemoval(removalCallback: @escaping () -> Void) {
        listeners.append(roomDocumentRef.addSnapshotListener { (document, _) in
            if let document = document {
                if !document.exists {
                    removalCallback()
                }
            }
        })

        listeners.append(playersCollectionRef.document(deviceId).addSnapshotListener { (document, _) in
            if let document = document {
                if !document.exists {
                    removalCallback()
                }
            }
        })
    }

    static func getConnection(for room: FirestoreRoom, removed removedCallback: @escaping () -> Void,
                              completion callback: @escaping (RoomConnection?, Error?) -> Void) {
        let connection = FirebaseRoomConnection(forRoom: room.name)

        func joinRoom(completion: @escaping (Error?) -> Void) {
            connection.playersCollectionRef.document(connection.deviceId)
                .setData([FirestoreConstants.lastHeartBeatKey: Date().timeIntervalSince1970]) { (error) in
                completion(error)
            }
        }

        func createAndJoinRoom(completion: @escaping (Error?) -> Void) {
            let batch = Firestore.firestore().batch()
            let data: [String: Any] = [FirestoreConstants.roomMasterKey: connection.deviceId,
                        FirestoreConstants.roomStartedKey: false]
            batch.setData(data, forDocument: connection.roomDocumentRef)
            connection.roomDocumentRef.setData([FirestoreConstants.roomMasterKey: connection.deviceId])
            connection.playersCollectionRef.document(connection.deviceId)
                .setData([FirestoreConstants.lastHeartBeatKey: Date().timeIntervalSince1970])

            batch.commit(completion: completion)
        }

        func postJoinActions(error: Error?) {
            if let error = error {
                callback(nil, error)
            }
            connection.subscribeRemoval(removalCallback: removedCallback)
            connection.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                connection.sendAndCheckHeartBeat()
            })
            connection.heartbeatTimer?.fire()
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
                joinRoom(completion: postJoinActions)
            } else {
                createAndJoinRoom(completion: postJoinActions)
            }
        }
    }

    private func sendAndCheckHeartBeat() {
        let currentTime = Date().timeIntervalSince1970
        playersCollectionRef.document(deviceId)
            .updateData([FirestoreConstants.lastHeartBeatKey: currentTime])
        playersCollectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error reading player documents. \(error.localizedDescription)")
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

                if currentTime - lastHeartBeat > 60 {
                    let playerName = document.documentID
                    /// Remove player
                    self?.playersCollectionRef.document(playerName).delete()

                    if playerName == self?.roomMasterId {
                        self?.roomDocumentRef.delete()
                    }
                }
            }
        }

    }

    func startGame(initialState: GameState, completion callback: @escaping (Error?) -> Void) throws {
        let batch = FirestoreConstants.firestore.batch()
        guard let data = try? FirestoreEncoder.init().encode(initialState) else {
            throw NetworkError.encodeError(message: FirestoreConstants.encodeStateErrorMsg)
        }

        batch.setData(data, forDocument: modelCollectionRef.document(FirestoreConstants.initialStateDocumentName))
        batch.updateData([FirestoreConstants.roomStartedKey: true], forDocument: roomDocumentRef)

        batch.commit(completion: callback)
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

    /// TODO: CHANGE TYPE
    func subscribeToActions(for turn: Int, callback: @escaping ([[PlayerAction]], Error?) -> Void) {
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
                    try FirebaseDecoder.init().decode([PlayerAction].self, from: $0.data())
                }
                callback(actions, nil)
            } catch {
                callback([],
                         NetworkError.pullError(message: "Error when decoding: \(error.localizedDescription)"))
            }
        })
    }

    /// TODO when teams are added.
    func subscribeToPlayerTeams(with callback: @escaping ([WaitingRoomPlayer]) -> Void) {
        let listener = playersCollectionRef.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                return
            }

            let players = snapshot.documents.map { (document) -> WaitingRoomPlayer in
                let team = document.get(FirestoreConstants.playerTeamKey) as? String
                let player = document.documentID
                return WaitingRoomPlayer(playerName: player, teamName: team)
            }

            callback(players)
        }
        listeners.append(listener)
    }

    private func push<T: Codable>(_ codable: T, to docRef: DocumentReference,
                                  encodeErrorMsg: String,
                                  completion callback: @escaping (Error?) -> Void) throws {
        guard let encoded = try? FirebaseEncoder.init().encode(codable),
            let data = encoded as? [String: Any] else {
                throw NetworkError.encodeError(message: encodeErrorMsg)
        }

        docRef.setData(data, completion: callback)
    }

    func push(actions: [PlayerAction], fromPlayer player: Player, forTurnNumbered turn: Int, completion callback: @escaping (Error?) -> ()) throws {
        /// TODO: Change collection
        /// Room doc -> runtimeinfo(col) -> TurnActions (doc) -> Turn1...Turn999 (col)
        try push(actions,
                 to: turnActionsDocumentRef.collection(String(turn)).document(player.name),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    func checkTurnEnd(actions: [Map], forTurnNumbered turn: Int) throws {

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

    func changeTeamName(for identifier: String, to teamName: String) {
        playersCollectionRef.document(identifier).updateData([FirestoreConstants.playerTeamKey: teamName])
    }

    deinit {
        self.heartbeatTimer?.invalidate()
        self.listeners.forEach { $0.remove() }
    }
}
