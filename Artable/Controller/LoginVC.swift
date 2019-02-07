//
//  LoginVC.swift
//  Artable
//
//  Created by Luca Lo Forte on 05/02/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func forgotPassPressed(_ sender: Any) {
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailTextField.text , email.isNotEmpty,
            let password = passwordTextField.text , password.isNotEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fields.")
                return
        }
        
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.activityIndicator.stopAnimating()
                self.handleFireAuthError(error: error)
                return
            }
            print("Login Successful")
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func guestPressed(_ sender: Any) {
    }
    
}
