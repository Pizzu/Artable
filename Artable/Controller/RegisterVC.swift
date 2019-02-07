//
//  RegisterVC.swift
//  Artable
//
//  Created by Luca Lo Forte on 05/02/2019.
//  Copyright © 2019 Luca Lo Forte. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {

    //Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passCheckImg: UIImageView!
    @IBOutlet weak var confirmPassCheckImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let passText = passwordTextField.text else { return }
        
        if textField == confirmPasswordTextField && passText.isNotEmpty {
            passCheckImg.isHidden = false
            confirmPassCheckImg.isHidden = false
        } else {
            if passText.isEmpty {
                passCheckImg.isHidden = true
                confirmPassCheckImg.isHidden = true
                confirmPasswordTextField.text = ""
            }
        }
        if passwordTextField.text == confirmPasswordTextField.text {
            passCheckImg.image = UIImage(named: AppImages.GreenCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.GreenCheck)
        } else {
            passCheckImg.image = UIImage(named: AppImages.RedCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.RedCheck)
        }
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        guard let email = emailTextField.text , email.isNotEmpty ,
            let username = usernameTextField.text , username.isNotEmpty,
            let password = passwordTextField.text , password.isNotEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all fields.")
                return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text , confirmPassword == password else {
            simpleAlert(title: "Error", message: "Passwords do not match.")
            return
        }
        
        activityIndicator.startAnimating()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        currentUser.linkAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error  {
                self.activityIndicator.stopAnimating()
                debugPrint(error.localizedDescription)
                self.handleFireAuthError(error: error)
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
