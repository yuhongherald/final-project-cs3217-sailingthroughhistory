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
    private let roomMasterId: String
    private let roomName: String
    private var heartbeatTimer: Timer?
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
        roomDocumentRef.addSnapshotListener { (document, _) in
            if let document = document {
                if !document.exists {
                    removalCallback()
                }
            }
        }

        playersCollectionRef.document(deviceId).addSnapshotListener { (document, _) in
            if let document = document {
                if !document.exists {
                    removalCallback()
                }
            }
        }
    }

    static func getConnection(for room: FirestoreRoom, removed removedCallback: @escaping () -> Void,
        completion callback: @escaping (RoomConnection?, Error?) -> ()) {
        let connection = FirebaseRoomConnection(forRoom: room.name)

        func joinRoom(completion: @escaping (Error?) -> ()) {
            connection.playersCollectionRef.document(connection.deviceId).setData([FirestoreConstants.lastHeartBeatKey: Date().timeIntervalSince1970]) { (error) in
                completion(error)
            }
        }

        func createAndJoinRoom(completion: @escaping (Error?) -> ()) {
            let batch = Firestore.firestore().batch()
            batch.setData([FirestoreConstants.roomMasterKey: connection.deviceId], forDocument:  connection.roomDocumentRef)
            connection.roomDocumentRef.setData([FirestoreConstants.roomMasterKey: connection.deviceId])
            connection.playersCollectionRef.document(connection.deviceId).setData([FirestoreConstants.lastHeartBeatKey: Date().timeIntervalSince1970])
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

    /// TODO: Change to GameState
    func push(state: Map, completion callback: @escaping (Error?) -> Void) throws {
        try push(state,
                 to: modelCollectionRef.document(FirestoreConstants.stateDocumentName),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    private func push<T: Codable>(_ codable: T, to docRef: DocumentReference, encodeErrorMsg: String, completion callback: @escaping (Error?) -> Void) throws {
        guard let encoded = try? FirebaseEncoder.init().encode(codable),
            let data = encoded as? [String: Any] else {
                throw NetworkError.encodeError(message: encodeErrorMsg)
        }

        docRef.setData(data, completion: callback)
    }

    func push(actions: [Map], fromPlayer player: Player, forTurnNumbered turn: Int, completion callback: @escaping (Error?) -> ()) throws {
        /// TODO: Change collection
        /// Room doc -> runtimeinfo(col) -> TurnActions (doc) -> Turn1...Turn999 (col)
        try push(actions,
                 to: turnActionsDocumentRef.collection(String(turn)).document(player.name),
                 encodeErrorMsg: FirestoreConstants.encodeStateErrorMsg,
                 completion: callback)
    }

    func checkTurnEnd(actions: [Map], forTurnNumbered turn: Int) throws {

    }

    deinit {
        self.heartbeatTimer?.invalidate()
    }
}
