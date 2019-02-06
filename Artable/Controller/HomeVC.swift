//
//  ViewController.swift
//  Artable
//
//  Created by Luca Lo Forte on 05/02/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {

    //Outlets
    @IBOutlet weak var loginOutBtn: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //If we have no user signed in (with email, or anonymously), we sign him anonymously
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (authResult, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if let currentUser = Auth.auth().currentUser , !currentUser.isAnonymous {
            loginOutBtn.title = "Logout"
        } else {
            loginOutBtn.title = "Login"
        }
    }
    
    private func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginOutPressed(_ sender: Any) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        if currentUser.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                //After the sign out (from signed in user with email) --> we set an Anonymous user
                Auth.auth().signInAnonymously { (authResult, error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                    self.presentLoginController()
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        
//        if let _ = Auth.auth().currentUser {
//            //We are logged in ---> Log out
//            do {
//                 try Auth.auth().signOut()
//                presentLoginController()
//            } catch {
//                debugPrint(error.localizedDescription)
//            }
//        } else {
//            //We are not logged in
//             presentLoginController()
//        }
    }
    
}

