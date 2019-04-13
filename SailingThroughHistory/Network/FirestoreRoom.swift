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

    init(named name: String) {
        self.name = name
        self.firestore = FirestoreConstants.firestore
    }

    private static func processRooms(snapshot: QuerySnapshot?, error: Error?) -> [Room] {
        guard let roomDocuments = snapshot?.documents else {
            fatalError("Failed to read rooms")
        }

        return roomDocuments
            .map { FirestoreRoom(named: $0.documentID) }
    }

    func getConnection(completion callback: @escaping (RoomConnection?, Error?) -> ()) {
        FirebaseRoomConnection.getConnection(for: self, completion: callback)
    }

    static func deleteIfNecessary(named name: String) {
        let devicesCollectionReference = FirestoreConstants
            .roomCollection
            .document(name)
            .collection(FirestoreConstants.devicesCollectionName)

        func deleteIfEmpty(_: Error?) {
            devicesCollectionReference.getDocuments(completion: { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Unable to load room players: \(String(describing: error?.localizedDescription))")
                    return
                }
                if snapshot.documents.count <= 0 {
                    FirestoreConstants.roomCollection.document(name).delete()
                    deleteAllRoomInformation(named: name)
                }
            })
        }

        devicesCollectionReference.getDocuments { (snapshot, error) in
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

    private static func deleteAllRoomInformation(named name: String) {
        let devicesCollectionReference = FirestoreConstants
            .roomCollection
            .document(name)
            .collection(FirestoreConstants.devicesCollectionName)
        let playersCollectionReference = FirestoreConstants
            .roomCollection
            .document(name)
            .collection(FirestoreConstants.playersCollectionName)
        for reference in [devicesCollectionReference, playersCollectionReference] {
            reference.getDocuments { (snapshot, _) in
                for document in snapshot?.documents ?? [] {
                    document.reference.delete()
                }
            }
        }
    }
}
