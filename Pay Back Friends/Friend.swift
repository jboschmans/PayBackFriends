//
//  Friend.swift
//  Pay Back Friends
//
//  Created by Joris Boschmans on 18/01/2017.
//  Copyright © 2017 Joris Boschmans. All rights reserved.
//

import UIKit

class Friend {
    let username: String
    var owed: Float
    
    init(username: String, owed: Float){
        self.username = username
        self.owed = owed
    }
}
