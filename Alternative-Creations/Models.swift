//
//  Models.swift
//  Alternative-Creations
//
//  Created by Rey Cerio on 2017-03-17.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var email: String?
    var fbId: String?
}

class Artist: NSObject {
    var name: String?
    var bio: String?
    var image: String?
    var artistId: String?
}

class Art: NSObject {
    var title: String?
    var artist: String?
    var artistId: String?
    var date: String?
    //never use var description
    var desc: String?
    var imageUrl: String?
}
