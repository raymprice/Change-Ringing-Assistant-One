//
//  MethodData.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 30/04/2020.
//  Copyright © 2020 Ray Price. All rights reserved.
//

import Foundation

struct MethodData {
    var methodName: String
    var bellCount: Int
    var methodStructure: String
    var methodArray: [[Int]]
    var bobValid: Bool
    var singleValid: Bool
    
    init(a: String, b:Int, c:String, d:[[Int]], e:Bool, f:Bool) {
        methodName = a
        bellCount = b
        methodStructure = c
        methodArray = d
        bobValid = e
        singleValid = f
    }
}

