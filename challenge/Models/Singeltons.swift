//
//  Singeltons.swift
//  challenge
//
//  Created by Denis Garifyanov on 27/09/2018.
//  Copyright © 2018 Denis Garifyanov. All rights reserved.
//

import Foundation

class Session {
    static let instance = Session()
    private init(){}
    
    var token = ""
    var id: Int = Int()
    
}
