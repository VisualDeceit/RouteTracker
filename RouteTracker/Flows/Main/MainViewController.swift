//
//  MainViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit

class MainViewController: UIViewController {

    @IBAction func showMapButtonTapped(_ sender: Any) {
       performSegue(withIdentifier: "toMap", sender: sender)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "logout", sender: sender)
    }
    
    override func loadView() {
        self.view = loadFromNibNamed(nibName: "MainViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
