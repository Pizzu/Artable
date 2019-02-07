//
//  ForgotPasswordVC.swift
//  Artable
//
//  Created by Luca Lo Forte on 07/02/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase
class ForgotPasswordVC: UIViewController {

    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordPressed(_ sender: Any) {
        guard let email = emailTextField.text , email.isNotEmpty else {
            simpleAlert(title: "Error", message: "Please enter email.")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.handleFireAuthError(error: error)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
