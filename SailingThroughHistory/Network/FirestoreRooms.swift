//
//  GameRooms.swift
//  SailingThroughHistory
//
//  Created by Jason Chong on 29/3/19.
//  Copyright © 2019 Sailing Through History Team. All rights reserved.
//

import FirebaseFirestore

/// Collection of rooms on the Firestore database.
class FirestoreRooms: NetworkRooms {
    private var rooms = [String]()
    private var callbacks = [([String]) -> Void]()
    private var listener: ListenerRegistration?

    init() {
        self.listener = FirestoreConstants
            .roomCollection
            .addSnapshotListener({ [unowned self] (snapshot, _) in
                guard let snapshot = snapshot else {
                    return
                }
                self.rooms = []
                for document in snapshot.documents {
                    let name = document.documentID
                    FirestoreRoom.deleteIfNecessary(named: name)
                    if !(document.data()[FirestoreConstants.roomStartedKey] as? Bool ?? false) {
                        self.rooms.append(name)
                    }
                }

                self.callbacks.forEach { $0(self.rooms) }
            })
    }

    func subscribe(with callback: @escaping ([String]) -> Void) {
        callback(self.rooms)
        callbacks.append(callback)
    }

    deinit {
        listener?.remove()
    }
}
