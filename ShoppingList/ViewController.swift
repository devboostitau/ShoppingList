//
//  ViewController.swift
//  ShoppingList
//
//  Created by Eric Alves Brito on 15/09/20.
//  Copyright © 2020 DevBoost. All rights reserved.
//

import UIKit
import Firebase

final class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelCopyright: UILabel!
    
    // MARK: - Properties
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        labelCopyright.text = RemoteConfigValues.shared.copyrightMessage
    }
    
    // MARK: - IBActions
    @IBAction func signIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { (result, error) in
            if let error = error {
                let authErrorCode = AuthErrorCode(rawValue: error._code)
                switch authErrorCode {
                case .invalidEmail:
                    print("E-mail inválido")
                case .wrongPassword:
                    print("Senha errada")
                default:
                    print(authErrorCode?.rawValue ?? "---")
                }
            } else {
                guard let user = result?.user else {return}
                self.updateUserAndProceed(user: user)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        Auth.auth().createUser(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { (result, error) in
            if let error = error {
                let authErrorCode = AuthErrorCode(rawValue: error._code)
                switch authErrorCode {
                case .emailAlreadyInUse:
                    print("E-mail já em uso")
                case .invalidEmail:
                    print("E-mail inválido")
                case .weakPassword:
                    print("Senha fraca")
                default:
                    print(authErrorCode?.rawValue ?? "---")
                }
            } else {
                
                guard let user = result?.user else {return}
                
                self.updateUserAndProceed(user: user)
            }
        }
    }
    
    // MARK: - Methods
    private func updateUserAndProceed(user: User) {
        //Auth.auth().currentUser
        if textFieldName.text!.isEmpty {
            gotoMainScreen()
        } else {
            let request = user.createProfileChangeRequest()
            request.displayName = textFieldName.text!
            request.commitChanges { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                self.gotoMainScreen()
            }
        }
    }
    
    private func gotoMainScreen() {
        let tableViewController = storyboard?.instantiateViewController(withIdentifier: "TableViewController")
        show(tableViewController!, sender: nil)
    }
}

