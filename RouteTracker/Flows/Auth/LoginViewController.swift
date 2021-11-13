//
//  LoginViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit
import RealmSwift

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
            checkUser(login: login, password: password)
        else {
            let alert = UIAlertController(title: "Ошибка", message: "Пользователь с такой комбинацией логина и пароля не найден", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(action)
            present(alert, animated: true)
            return
        }

        UserDefaults.standard.set(true, forKey: "isLogin")
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

extension LoginViewController {
    func checkUser(login: String, password: String) -> Bool {
        do {
            let realm = try Realm()
            print(String(describing: realm.configuration.fileURL))
            let user = realm.objects(User.self).where {
                $0.login == login && $0.password == password
            }
            return user.count > 0 ? true : false
        } catch {
            return false
        }
    }
}
