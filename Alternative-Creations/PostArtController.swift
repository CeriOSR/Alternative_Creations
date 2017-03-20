//
//  PostArtController.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-17.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class PostArtController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var artistPickerView: UIPickerView!
    @IBOutlet weak var artImageview: UIImageView!
    var artist = [Artist]()
    var pickerArtist = Artist()  //pickerView
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        artImageview.image = #imageLiteral(resourceName: "alt_cre_logo")
        artImageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectArtImage)))
        artistPickerView.delegate = self
        artistPickerView.dataSource = self
        fetchArtist()
        
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        handleLogout()
    }
    
    @IBAction func postArtButton(_ sender: Any) {
        storeImageToStorage()
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
        performSegue(withIdentifier: "postArtLogoutSegue", sender: self)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    //image picker
    func handleSelectArtImage () {
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
            artImageview.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return artist.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return artist[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return pickerArtist = artist[row]
    }
        
    func fetchArtist() {
        let artistRef = FIRDatabase.database().reference().child("artist_ref")
        artistRef.observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            FIRDatabase.database().reference().child("Artist").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String: AnyObject]
                let fetchedArtist = Artist()
                fetchedArtist.name = dictionary?["name"] as? String
                fetchedArtist.bio = dictionary?["bio"] as? String
                fetchedArtist.image = dictionary?["image"] as? String
                fetchedArtist.artistId = id
                self.artist.append(fetchedArtist)
                DispatchQueue.main.async(execute: { 
                    self.artistPickerView.reloadAllComponents()
                })
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    //store image to storage
    func storeImageToStorage() {
        let storageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("art").child(storageName)
        if let image = artImageview.image, let uploadImage = UIImageJPEGRepresentation(image, 0.5) {
            storageRef.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    self.createAlert(title: "Storage Failed", message: "Something went wrong with the database. Try again.")
                    return
                }
                let imageUrl = metadata?.downloadURL()?.absoluteString
                guard let unwrappedURL = imageUrl else {return}
                self.assigningValuesForDatabase(imageUrl: unwrappedURL)
            })
            
        }
    }
    
    //store to database
    func assigningValuesForDatabase(imageUrl: String){
        guard let title = titleTextField.text else {return}
        guard let description = descriptionTextView.text else {return}
        guard let artist = pickerArtist.name else {return}
        guard let artistId = pickerArtist.artistId else {return}
        let date = Date()
        let dateString = String(describing: date)
        
        let values = ["title": title, "description": description, "artist": artist, "artistId": artistId, "date": dateString, "imageUrl": imageUrl] as [String : Any]
        storeInDatabase(values: values as [String : AnyObject], artistId: artistId)
        
    }
    
    func storeInDatabase(values: [String: AnyObject], artistId: String) {
        //guard let title = titleTextField.text else {return}
        let dataRef = FIRDatabase.database().reference().child("art").childByAutoId()
        dataRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                self.createAlert(title: "Storage Failed", message: "Please try again.")
                return
            }
            let fanRef = FIRDatabase.database().reference().child("art_ref").child(artistId)
            fanRef.updateChildValues([dataRef.key:1])
            self.createAlert(title: "New Art Posted", message: "Check it out under the artist.")
            self.titleTextField.text = ""
            self.descriptionTextView.text = "Description..."
            self.artImageview.image = #imageLiteral(resourceName: "alternative_creations")
            
        }
    }
}
