//
//  FirebaseRoom.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 27/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseFirestore

/// A room stored on Firestore.
class FirestoreRoom: Room {
    /// The name of the room
    let name: String
    /// Reference to Firestore
    private let firestore: Firestore

    init(named name: String) {
        self.name = name
        self.firestore = FirestoreConstants.firestore
    }

    /// Get Room objects from a QuerySnapshot
    ///
    /// - Parameters:
    ///   - snapshot: The result of the query as a QuerySnapshot
    ///   - error: The error from the query
    /// - Returns: The array of rooms stored in the snapshot.
    private static func processRooms(snapshot: QuerySnapshot?, error: Error?) -> [Room] {
        guard let roomDocuments = snapshot?.documents else {
            fatalError("Failed to read rooms")
        }

        return roomDocuments
            .map { FirestoreRoom(named: $0.documentID) }
    }

    func getConnection(completion callback: @escaping (RoomConnection?, Error?) -> Void) {
        FirebaseRoomConnection.getConnection(for: self, completion: callback)
    }

    /// Deletes a room on the network if necessary.
    /// i.e If all the devices in the room are not responsive or the room is empty.
    ///
    /// - Parameter name: The name of the room.
    static func deleteIfNecessary(named name: String) {
        let devicesCollectionReference = FirestoreConstants
            .roomCollection
            .document(name)
            .collection(FirestoreConstants.devicesCollectionName)
        let connection = FirebaseRoomConnection(forRoom: name)
        func deleteIfEmpty(_: Error?) {
            devicesCollectionReference.getDocuments(completion: { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Unable to load room players: \(String(describing: error?.localizedDescription))")
                    return
                }
                if snapshot.documents.count <= 0 {
                    FirebaseRoomConnection.deleteRoom(named: name)
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
                        connection.removeDevice(withId: document.documentID)
                        continue
                }
            }
            deleteIfEmpty(nil)
        }
    }
}
