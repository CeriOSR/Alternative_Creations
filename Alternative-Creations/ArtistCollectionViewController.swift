//
//  ArtistCollectionViewController.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-17.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

private let reuseIdentifier = "ArtistCell"
var selectedArtist = Artist()


class ArtistCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var artists = [Artist]()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserExist()
        navigationController?.navigationBar.isHidden = false
        if FIRAuth.auth()?.currentUser?.email == "ceriosrey@gmail.com" {
            tabBarController?.tabBar.isHidden = false
        } else {
            tabBarController?.tabBar.isHidden = true
        }
        
        fetchArtist()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        //switch the scroll direction of a UICollectionView Controller
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artists.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ArtistCell
        let artist = artists[indexPath.item]
        cell.nameLabel.text = artist.name
        cell.bioLabel.text = artist.bio
        if let urlString = artist.image {
            cell.artistImageView.loadImageWithCacheOrUrlSession(urlString: urlString)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedArtist = artists[indexPath.item]
        performSegue(withIdentifier: "artistToArtSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "artistToArtSegue" {
            //use this if using segues to pass data instead of the commented one.
            let artCollectionController = segue.destination as! ArtCollectionController
            artCollectionController.artist = selectedArtist
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    func checkIfUserExist(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid == nil {
            handleLogout()
        }
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
        performSegue(withIdentifier: "artistCollectionLogoutSegue", sender: self)
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
                self.artists.append(fetchedArtist)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            }, withCancel: nil)
        }, withCancel: nil)
    }
}


class ArtistCell: UICollectionViewCell {
    
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
//    override func prepareForReuse() {
//        artistImageView.image = nil
//        nameLabel.text = nil
//        bioLabel.text = nil
//    }
    
}


