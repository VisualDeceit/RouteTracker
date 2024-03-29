//
//  LoginViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    private let bag = DisposeBag()
    private var isNeedShowBar = false
    
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func loadView() {
        self.view = loadFromNibNamed(nibName: "LoginViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.string(forKey: "user") != nil {
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isNeedShowBar {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(hideKeyboardGesture)
        configureLoginBindings()
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

        UserDefaults.standard.set(login, forKey: "user")
        performSegue(withIdentifier: "toMain", sender: sender)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: sender)
    }
    
    @IBAction func logoutButtonTapped(_ segue: UIStoryboardSegue) {
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        isNeedShowBar = segue.identifier == "toSignUp" ? true : false
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func configureLoginBindings() {
        Observable
            .combineLatest(
                loginView.rx.text,
                passwordView.rx.text)
            .map { login, password in
                return !(login ?? "").isEmpty && (password ?? "").count >= 6
            }
            .bind { [weak loginButton] inputFilled in
                loginButton?.isEnabled = inputFilled
            }.disposed(by: bag)
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
