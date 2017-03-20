//
//  ExpandedViewController.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-19.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

class ExpandedViewController: UIViewController {

    var art: Art?
    
    @IBOutlet weak var expandedImageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = art?.title
        if let urlString = art?.imageUrl {
            expandedImageView.loadImageWithCacheOrUrlSession(urlString: urlString)
        }
        descriptionLabel.text = art?.desc

    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }

    @IBAction func backButton(_ sender: Any) {
        
        performSegue(withIdentifier: "backToArtCollectionControllerSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToArtCollectionControllerSegue" {
            //use this if using segues to pass data instead of the commented one.
            let artCollectionController = segue.destination as! ArtCollectionController //ArtCollectionController()
            artCollectionController.artist = selectedArtist
            //artCollectionController.selectedArtist = selectedArtist
        }
    }

}
