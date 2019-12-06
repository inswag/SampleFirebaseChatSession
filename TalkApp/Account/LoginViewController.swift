//
//  LoginViewController.swift
//  TalkApp
//
//  Created by 박인수 on 17/11/2019.
//  Copyright © 2019 inswag. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // Text
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButtonAction()
    }
    
    func addButtonAction() {
        loginButton.addTarget(self, action: #selector(actionSignIn), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(actionSignUp), for: .touchUpInside)
    }
    
    @objc func actionSignIn() {
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (auth, err) in
            if err == nil {
                self.performSegue(withIdentifier: "MainSegue", sender: nil)
            } else {
                print(err)
            }
        }
    }

    @objc func actionSignUp() {
        performSegue(withIdentifier: "SignUpSegue", sender: nil)
    }
    
}
