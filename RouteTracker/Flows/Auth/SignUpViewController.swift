//
//  SignUpViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit

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
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}
