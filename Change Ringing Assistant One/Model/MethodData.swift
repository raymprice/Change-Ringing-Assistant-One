//
//  MethodData.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 30/04/2020.
//  Copyright © 2020 Ray Price. All rights reserved.
//

import Foundation

struct MethodData {
    let methodName: String
    let bellCount: Int
    let methodArray: [[Int]]
    let bobValid: Bool
    let singleValid: Bool
    
    init(a: String, b:Int, c:[[Int]], d:Bool, e:Bool) {
        methodName = a
        bellCount = b
        methodArray = c
        bobValid = d
        singleValid = e
    }
}

