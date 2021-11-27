//
//  MainViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit

class MainViewController: UIViewController {
    private var isNeedShowBar = false

    @IBAction func showMapButtonTapped(_ sender: Any) {
       performSegue(withIdentifier: "toMap", sender: sender)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "logout", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        isNeedShowBar = segue.identifier == "toMap" ? true : false
    }
    
    override func loadView() {
        self.view = loadFromNibNamed(nibName: "MainViewController")
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
    }
}
