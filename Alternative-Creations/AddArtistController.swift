//
//  AddArtistController.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-17.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class AddArtistController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var avatarImageView: UIImageView!
    var avatarImage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        avatarImageView.image = #imageLiteral(resourceName: "people-icon--icon-search-engine-18")
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectArtistImage)))
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    @IBAction func addArtistButton(_ sender: UIBarButtonItem) {
        //handleSubmitArtistImageToStorage()
        let storageImageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("artist").child("\(storageImageName)")
        if let image = avatarImageView.image, let uploadImage = UIImageJPEGRepresentation(image, 0.1) {
            storageRef.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    self.createAlert(title: "Storing Failed", message: "Could not store image to database.")
                    return
                }
                if let eventUrl = metadata?.downloadURL()?.absoluteString {
                    self.avatarImage = eventUrl
                    self.assigningValuesToBeStoredToDatabase()
                }
            })
        }

    }
    
    @IBAction func logoutButton(_ sender: Any) {
        handleLogout()
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        }catch let err {
            print(err)
            return
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        performSegue(withIdentifier: "addArtistLogoutSegue", sender: self)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleSubmitArtistImageToStorage() {
        let storageImageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("artist").child("\(storageImageName)")
        if let image = avatarImageView.image, let uploadImage = UIImageJPEGRepresentation(image, 0.1) {
            storageRef.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    self.createAlert(title: "Storing Failed", message: "Could not store image to database.")
                    return
                }
                if let eventUrl = metadata?.downloadURL()?.absoluteString {
                    self.avatarImage = eventUrl
                    self.assigningValuesToBeStoredToDatabase()
                }
            })
        }
    }
    
    func assigningValuesToBeStoredToDatabase() {
        guard let name = nameTextField.text else {return}
        guard let bio = bioTextView.text else {return}
        guard let image = avatarImage as String? else {return}
        
        let values = ["name": name, "bio": bio, "image": image]
        
        handleSubmit(values: values as [String : AnyObject])
    }
    
    func handleSubmit(values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("Artist")
        let childref = ref.childByAutoId()
        childref.updateChildValues(values) { (error, reference) in
            if let err = error {
                self.createAlert(title: "Could not submit artist!", message: err as! String)
                return
            }
            FIRDatabase.database().reference().child("artist_ref").updateChildValues([childref.key:1])
            
            self.createAlert(title: "Artist submitted!", message: "Check out you newly added Artist!")
            self.bioTextView.text = "Enter bio..."
            self.nameTextField.text = nil
            self.avatarImageView.image = #imageLiteral(resourceName: "people-icon--icon-search-engine-18")
        }
    }
    
    //image picker
    func handleSelectArtistImage () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker = UIImage()
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker as UIImage?{
            avatarImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
