//
//  UserService.swift
//  Artable
//
//  Created by Luca Lo Forte on 05/03/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import Foundation

let UserService = _UserService()
import Firebase
import CodableFirebase

final class _UserService {
    
    var user = User()
    let auth = Auth.auth()
    var listener : ListenerRegistration? = nil
    
    var isGuest : Bool {
        guard let authUser = Auth.auth().currentUser else {
            return true
        }
        if authUser.isAnonymous {
            return true
        } else {
            return false
        }
    }
    
    func getCurrentUser() {
        guard let authUser = auth.currentUser else { return }
        let userRef = Firestore.firestore().collection("users").document(authUser.uid)
        listener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            if let data = snap?.data() {
                do {
                    self.user = try FirestoreDecoder().decode(User.self, from: data)
                    print(self.user)
                } catch {
                    debugPrint(error)
                }
            }
        })
    }
    
    func logoutUser() {
        UserService.listener?.remove()
        UserService.listener = nil
        user = User()
    }
}
