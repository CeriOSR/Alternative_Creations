//
//  ViewController.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-15.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        let loginButton = FBSDKLoginButton()
        //loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        //using frames because autolayout wont let me increase the size
        loginButton.frame = CGRect(x: 16, y: 450, width: view.frame.width - 32, height: 40)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
    }
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Could not continue with Facebook!", error)
            return
        }
        let user = User()
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print("Could not get Facebook details.")
                return
            }
            let fBdictionary = result as? [String: AnyObject]
            user.email = fBdictionary?["email"] as? String
            user.fbId = fBdictionary?["id"] as? String
            user.name = fBdictionary?["name"] as? String
            let values = ["id": user.fbId, "email": user.email, "name": user.name]
            
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else {return}
            let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                    print("Could not authenticate user!", error ?? "unknown error")
                    return
                }
                
                self.storeUserToDatabase(values: values as Dictionary<String, AnyObject>)
                
            })

        }

    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout of Facebook!!!!")
    }
    
    func storeUserToDatabase(values: Dictionary<String, AnyObject>) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let userRef = FIRDatabase.database().reference().child("users").child(uid)
        userRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                print("Could not store user to database!", error ?? "unkown error")
                return
            }
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
}

