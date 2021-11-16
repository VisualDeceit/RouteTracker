//
//  SignUpViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit
import RealmSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    
    override func loadView() {
        self.view = loadFromNibNamed(nibName: "SignUpViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard
            let login = loginView.text,
            let password = passwordView.text
        else {
            let alert = UIAlertController(title: "Ошибка", message: "Введите имя пользователя и пароль", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(action)
            present(alert, animated: true)
            return
        }
        
        do {
            try registerUser(login: login, password: password)
        } catch {
            let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(action)
            present(alert, animated: true)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

extension SignUpViewController {
    func registerUser(login: String, password: String) throws {
        let realm = try Realm()
        if let user = realm.object(ofType: User.self, forPrimaryKey: login) {
            try realm.write {
                user.password = password
            }
        } else {
            let user = User()
            user.login = login
            user.password = password
            try realm.write{
                realm.add(user)
            }
        }
    }
}
