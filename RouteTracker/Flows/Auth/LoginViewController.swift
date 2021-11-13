//
//  LoginViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit

fileprivate enum Constants {
    static let login = "admin"
    static let password = "123456"
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    
    override func loadView() {
        self.view = loadFromNibNamed(nibName: "LoginViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(hideKeyboardGesture)
    }
 
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard
            let login = loginView.text,
            let password = passwordView.text,
            login == Constants.login && password == Constants.password
        else {
            return
        }
        print("Логин")
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private func loadFromNibNamed(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName:nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
