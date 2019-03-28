//
//  FirebaseRoom.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseFirestore

class FirestoreRoom: Room {
    let name: String
    private let firestore: Firestore

    init(named name: String, firestore: Firestore) {
        self.name = name
        self.firestore = firestore
    }

    static func getAllRooms(completion callback: @escaping ([Room]) -> Void) {
        FirestoreConstants.roomCollection.getDocuments { (snapshot, error) in
            callback(processRooms(snapshot: snapshot, error: error))
        }
    }

    private static func processRooms(snapshot: QuerySnapshot?, error: Error?) -> [Room] {
        guard let roomDocuments = snapshot?.documents else {
            fatalError("Failed to read rooms")
        }

        return roomDocuments
            .map { FirestoreRoom(named: $0.documentID, firestore: Firestore.firestore()) }
    }

    func getConnection(removalCallback: @escaping () -> Void,
                       completion callback: @escaping (RoomConnection?, Error?) -> ()) {
        FirebaseRoomConnection.getConnection(for: self, removed: removalCallback, completion: callback)
    }

    static func deleteIfNecessary(named name: String) {
        let playerCollectionReference = FirestoreConstants.roomCollection.document(name).collection(FirestoreConstants.playersCollectionName)

        func deleteIfEmpty(_: Error?) {
            playerCollectionReference.getDocuments(completion: { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Unable to load room players: \(String(describing: error?.localizedDescription))")
                    return
                }

                if snapshot.documents.count <= 0 {
                    FirestoreConstants.roomCollection.document(name).delete()
                }
            })
        }

        playerCollectionReference.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Unable to load room players: \(String(describing: error?.localizedDescription))")
                return
            }

            for document in snapshot.documents {
                guard let lastHeartBeat = document.get(FirestoreConstants.lastHeartBeatKey)
                    as? Double,
                    Date().timeIntervalSince1970 - lastHeartBeat < 60 else {
                        document.reference.delete(completion: deleteIfEmpty)
                        return
                }
            }
        }
    }
}
