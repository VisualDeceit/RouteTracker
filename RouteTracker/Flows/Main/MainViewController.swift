//
//  MainViewController.swift
//  RouteTracker
//
//  Created by Александр Фомин on 13.11.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    private var isNeedShowBar = false
    private var avatarImage: UIImage!
    
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBAction func showMapButtonTapped(_ sender: Any) {
       performSegue(withIdentifier: "toMap", sender: sender)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "logout", sender: sender)
    }
    
    @IBAction func changeAvatarButtonTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap",
           let controller = segue.destination as? MapViewController{
            isNeedShowBar = true
            controller.avatarImage = self.avatarImage
        } else {
            isNeedShowBar = false
        }
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
        if let image = loadAvatarFromDB() {
            avatarImage = image
            avatarImageView.image = avatarImage
        } else {
            avatarImage = UIImage(named: "ava_placeholder")
            avatarImageView.image = avatarImage
        }
    }
}

extension MainViewController: UINavigationControllerDelegate & UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newAvatar = extractImage(from: info) {
            avatarImage = newAvatar
            avatarImageView.image = avatarImage
            saveAvatarToDB(image: newAvatar)
        }
        picker.dismiss(animated: true)
    }

    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[.editedImage] as? UIImage {
            return image
        } else if let image = info[.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}

// MARK: - Realm
extension MainViewController {
    func loadAvatarFromDB() -> UIImage? {
        do {
            let realm = try Realm()
            let login = UserDefaults.standard.string(forKey: "user")
            let user = realm.object(ofType: User.self, forPrimaryKey: login)
            guard let imageData = user?.avatar else { return nil }
            return UIImage(data: imageData)
        } catch {
            print(error)
            return nil
        }
    }
    
    func saveAvatarToDB(image: UIImage) {
        do {
            let realm = try Realm()
            let login = UserDefaults.standard.string(forKey: "user")
            if let user = realm.object(ofType: User.self, forPrimaryKey: login) {
                try realm.write {
                    user.avatar = image.pngData()!
                }
            }
        } catch {
            print(error)
        }
    }
}
