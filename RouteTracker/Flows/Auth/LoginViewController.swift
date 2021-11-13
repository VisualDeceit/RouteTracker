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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Показав контроллер авторизации, проверяем: если мы авторизованы,
        // сразу переходим к основному сценарию
        if UserDefaults.standard.bool(forKey: "isLogin") {
            performSegue(withIdentifier: "toMain", sender: self)
        }
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
        // Сохраним флаг, показывающий, что мы авторизованы
        UserDefaults.standard.set(true, forKey: "isLogin")
        // Перейдём к главному сценарию
        performSegue(withIdentifier: "toMain", sender: sender)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: sender)

    }
    
    @IBAction func logoutButtonTapped(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.set(false, forKey: "isLogin")
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}
