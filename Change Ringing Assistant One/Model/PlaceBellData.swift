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
    var placeBellCode: String?
    var bobArray: [Int]?
    var singleArray: [Int]?
	var methodSymmetry: String?
    
	init(a: String, b:String? = nil, c:[Int]? = nil, d:[Int]? = nil, e:String? = nil) {
        methodName = a
		placeBellCode = b
        bobArray = c
        singleArray = d
		methodSymmetry = e
    }
}
