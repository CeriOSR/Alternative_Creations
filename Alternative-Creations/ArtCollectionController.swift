//
//  ArtCollectionController.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-18.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "artCell"

class ArtCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var artist = Artist()
    var artArray = [Art]()
    var selectedArt = Art()
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.title = artist.name
        artist = selectedArtist
        fetchArtForArtist()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        //switch the scroll direction of a UICollectionView Controller
//        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .horizontal
//        }

    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ArtCell
        let art = artArray[indexPath.item]
        if let urlString = art.imageUrl {
            cell.artImageView.loadImageWithCacheOrUrlSession(urlString: urlString)
        }
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedArt = artArray[indexPath.item]
        performSegue(withIdentifier: "expandedArtSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.destination {
//            
//        case let expandedViewController as ExpandedViewController:
//            expandedViewController.art = selectedArt
//            
//        //case /add more cases here later maybe a buy button....
//            
//        default:
//            return
//        }
        
        if segue.identifier == "expandedArtSegue" {
            let expandedViewController = segue.destination as! ExpandedViewController
            expandedViewController.art = selectedArt
        }
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    @IBAction func backBarButton(_ sender: Any) {
        
        performSegue(withIdentifier: "backToArtistCollectionSegue", sender: self)

    }
    
    @IBAction func testButton(_ sender: UIBarButtonItem) {
        print(artist.name ?? "no name")
        print(12345)
    }
    
    func fetchArtForArtist() {
        guard let artistId = artist.artistId else {return}
        
        let fanRef = FIRDatabase.database().reference().child("art_ref").child(artistId)
        fanRef.observe(.childAdded, with: { (snapshot) in
            let artId = snapshot.key
            let artRef = FIRDatabase.database().reference().child("art").child(artId)
            artRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String: AnyObject]
                let art = Art()
                art.artist = dictionary?["artist"] as? String
                art.artistId = dictionary?["artistId"] as? String
                art.date = dictionary?["date"] as? String
                art.desc = dictionary?["description"] as? String
                art.imageUrl = dictionary?["imageUrl"] as? String
                art.title = dictionary?["title"] as? String
                self.artArray.append(art)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
}

class ArtCell: UICollectionViewCell {
    
    @IBOutlet weak var artImageView: UIImageView!
    
    
    override func prepareForReuse() {
        artImageView.image = nil
    }
}
