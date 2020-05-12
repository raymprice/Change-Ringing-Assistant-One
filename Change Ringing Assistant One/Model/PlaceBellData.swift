//
//  PlaceBellData.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 12/05/2020.
//  Copyright © 2020 Ray Price. All rights reserved.
//

import Foundation

struct PlaceBellData {
    var methodName: String
    var placeBellCode: String
    var bobArray: [Int]
    var singleArray: [Int]
    
    init(a: String, b:String, c:[Int], d:[Int]) {
        methodName = a
        placeBellCode = b
        bobArray = c
        singleArray = d
    }
}
