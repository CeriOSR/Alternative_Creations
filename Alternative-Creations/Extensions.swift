//
//  Extensions.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-17.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

private let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageWithCacheOrUrlSession(urlString: String) {
        self.image = nil
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cacheImage  //check cache if something in it then apply to image and return
            return
        } else { //if not download image with URLSession
            guard let url = URL(string: urlString) else {return}
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error ?? "unknown error")
                }
                DispatchQueue.main.async(execute: {
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                    }
                })
            }.resume() //must resume a URLSession
        }
    }
}

//manage rotation of navigation controller
extension UINavigationController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let visibleVC = visibleViewController {
                return visibleVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }}

//set the rotatation of tab controller
extension UITabBarController {
    
    override open var shouldAutorotate: Bool {
        get {
            if let selectedVC = selectedViewController{
                return selectedVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get {
            if let selectedVC = selectedViewController{
                return selectedVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            if let selectedVC = selectedViewController{
                return selectedVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }}

//Lock to Specific Orientation
//
//class YourViewController: UIViewController {
//    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
//        get {
//            return .portrait
//        }
//    }}
//Disable Rotation
//
//class YourViewController: UIViewController {
//    open override var shouldAutorotate: Bool {
//        get {
//            return false
//        }
//    }}
//Change Preferred Interface Orientation For Presentation
//
//class YourViewController: UIViewController {
//    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
//        get {
//            return .portrait
//        }
//    }}
