//
//  MethodFinder.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 30/04/2020.
//  Copyright © 2020 Ray Price. All rights reserved.
//

import Foundation

struct MethodFinder {
    
    
    //-------------------------
    // Method structures.
    // Bells MUST be in numerical order.
    //-------------------------
    
/******
     Dummy method.
     
    MethodData(a: "Method Name",
               b: 0,  // bell count,
               c: [
                [1, 1,2,3,4,5,5,4,3,2,1,901],
                [2, 102,1,1,2,3,4,105,5,4,3,902],
                [3, 3,4,5,105,4,3,2,1,1,102,903],
                [4, 4,103,2,1,1,2,3,104,5,5,904],
                [5, 5,5,104,3,2,1,1,2,103,4,905]
        ],
               d: false, // BOB allowed.
               e: false  // SINGLE allowed
    ),
 
 *****/
    
    
    
    
    let methodList = [
        // Minimus methods.
        [
            MethodData(a: "Plain Hunt",
                       b: 4,
                       c: [
                        [1, 1,2,3,4,4,3,2,1,     901],
                        [2, 102,1,1,2,3,104,4,3, 902],
                        [3, 3,4,104,3,2,1,1,102, 903],
                        [4, 4,103,2,1,1,2,103,4, 904]
                ],
                       d: false,
                       e: false
            ),
        
        MethodData(a: "Plain Bob",
                   b: 4,
                   c: [
                    [1, 1,2,3,4,4,3,2,1, 901],
                    [2, 102,1,1,2,103,4,4,3, 904],
                    [3, 3,4,104,3,2,1,1,102, 902],
                    [4, 4,103,2,1,1,2,103,4, 903]
            ],
                   d: false,
                   e: false)
        ],
        
        
        // Doubles methods.
        [
            MethodData(a: "Plain Hunt Doubles",
                       b: 5,
                       c: [
                        [1, 1,2,3,4,5,5,4,3,2,1,901],
                        [2, 102,1,1,2,3,4,105,5,4,3,902],
                        [3, 3,4,5,105,4,3,2,1,1,102,903],
                        [4, 4,103,2,1,1,2,3,104,5,5,904],
                        [5, 5,5,104,3,2,1,1,2,103,4,905]
                ],
                       d: false,
                       e: false
            ),
            
            MethodData(a: "Plain Bob Doubles",
                       b: 5,
                       c: [
                        [1, 1,2,3,4,5,5,4,3,2,     500,  1,901],
                        [2, 102,1,1,2,3,4,105,5,4, 500,  3,802,904],
                        [3, 3,4,5,105,4,3,2,1,1,   500,102,803,902],
                        [4, 4,103,2,1,1,2,3,104,5, 500,  5,905],
                        [5, 5,5,104,3,2,1,1,2,103, 500,  4,804,903]
                ],
                       d: true,
                       e: false
                
            ),
            
            MethodData(a: "Grandsire Doubles",
                       b: 5,
                       c: [
                        [1,  1,2,3,4,5,5,4,3,     500,   2,1,901],
                        [2,  102,1,1,2,3,4,105,5, 500,   4,753,853,   3,703,902],
                        [3,  3,103,2,1,1,2,3,104, 500,   5,754,854,   5,700,904],
                        [4,  4,5,104,3,2,1,1,2,   500, 103,752,852,   4,700,905],
                        [5,  5,4,5,105,4,3,2,1,   500,   1,102,702, 103,700,903]
                ],
                       d: true,
                       e: true
            ),
            MethodData(a: "St Simon's Doubles",
                       b: 5,
                       c: [
                        [1,  1,  2,  3,  4, 5, 5,  4,  3,  2, 500,  1,801, 901],
                        [2,102,  1,  1,  2, 1, 2,  1,  2,103, 500,  4,804, 903],
                        [3,  3,  4,  5,105, 4, 3,  3,104,  5, 500,  5,805, 905],
                        [4,  4,103,  2,  1, 2, 1,  2,  1,  1, 500,102,303, 902],
                        [5,  5,  5,104,  3, 3, 4,105,  5,  4, 500,  3,802, 904]
                ],
                       d: true,
                       e: false
            ),
            MethodData(a: "St Martin's Doubles",
                       b: 5,
                       c: [
                        [1,  1,  2,  3,  4, 5, 5,  4,  3,  2, 500,  1,801, 901],
                        [2,102,  1,  1,  2, 2, 1,  1,  2,103, 500,  4,804, 903],
                        [3,  3,  4,  5,105, 4, 3,  3,104,  5, 500,  5,805, 905],
                        [4,  4,103,  2,  1, 1, 2,  2,  1,  1, 500,102,803, 902],
                        [5,  5,  5,104,  3, 3, 4,105,  5,  4, 500,  3,802, 904]
                ],
                       d: true,
                       e: false
            ),
            MethodData(a: "Stedman Doubles",
                       b: 5,
                       c: [
                        [1,  1,2,3,4,5,500,4,755,  700,5,4,5,5,4,500,  5,705,904],
                        [2,  2,1,1,2,1,500,1,  0,  700,2,3,3,4,5,500,  4,704,905],
                        [3,  3,3,2,1,2,500,3,  0,  700,3,2,1,2,3,500,  3,700,902],
                        [4,  4,5,4,3,3,500,2,  0,  700,1,1,2,1,1,500,  2,700,903],
                        [5,  5,4,5,5,4,500,5,751,  700,4,5,4,3,2,500,  1,700,901]
                ],
                       d: false,
                       e: true)
        ],
        // Minor methods.
        [
            
            MethodData(a: "Plain Hunt Minor",
                       b: 6,
                       c: [
                        [1,1,2,3,4,5,6,6,5,4,3,2,1,901],
                        [2,102,1,1,2,3,4,5,106,6,5,4,3,902],
                        [3,3,4,5,6,106,5,4,3,2,1,1,102,903],
                        [4,4,103,2,1,1,2,3,4,105,6,6,5,904],
                        [5,5,6,6,105,4,3,2,1,1,2,103,4,905],
                        [6,6,5,104,3,2,1,1,2,3,104,5,6,906]
                ],
                       d: false,
                       e: false
            ),
            

            MethodData(a: "Plain Bob",
                       b: 6,
                       c: [
                        [1, 1,2,3,4,5,6,6,5,4,3,2,    500,1, 901],
                        [2, 102,1,1,2,3,4,5,106,6,5,4,500,3, 703,802, 904],
                        [3, 3,4,5,6,106,5,4,3,2,1,1,500,102, 702,803, 902],
                        [4, 4,103,2,1,1,2,3,4,105,6,6,500,5, 704,804, 906],
                        [5, 5,6,6,105,4,3,2,1,1,2,103,500,4, 703,803, 903],
                        [6, 6,5,104,3,2,1,1,2,3,104,5,500,6, 705,805, 905]
                ],
                       d: true, // BOB allowed.
                       e: true  // SINGLE allowed
            ),
            
            MethodData(a: "Cambridge Surprise Minor",
                       b: 6,
                       c: [
                        [1,   1,  2,  1,  2,  3,  4,  3,  4,  5,  6,  5,  6,  6,  5,  6,  5,  4,  3,  4,  3,  2,  1,  2, 500,   1, 901],
                        [2, 102,  1,102,  1,  1,  2,  2,  1,  2,  1,  1,  2,  1,  2,  3,  4,105,  6,105,  6,  5,  6,  6, 500,   5,706, 806, 906],
                        [3,   3,  4,  5,  6,  5,  6,  5,  6,106,  5,106,  5,  5,106,  5,106,  6,  5,  6,  5,  6,  5,  4, 500,   3,703, 802, 904],
                        [4,   4,103,  3,  4,104,  3,104,  3,  3,  4,  4,  3,  4,  3,  2,  1,  2,  1,  1,  2,103,  4,  5, 500,   6,705, 805, 905],
                        [5,   5,  6,  6,  5,  6,105,  6,105,  4,  3,  2,  1,  2,  1,  1,  2,  1,  2,  2,  1,  1,102,  1, 500, 102,702, 803, 902],
                        [6,   6,  5,  4,103,  2,  1,  1,  2,  1,  2,  3,  4,  3,  4,  4,  3,  3,104,  3,104,  4,  3,103, 500,   4,704, 804, 903]
                ],
                       d: true,
                       e: true
            )
            
        ],
        // Triples methods.
        
        [
            
            MethodData(a: "Grandsire Triples",
                       b: 7,
                       c: [
                        [1,   1,  2,  3,  4,  5,  6,  7,  7,  6,  5,  4,  3, 500,   2,701,801,  1,    901],
                        [2, 102,  1,  1,  2,  3,  4,  5,  6,107,  7,  6,  5, 500,   4,753,853,  3,703,902],
                        [3,   3,103,  2,  1,  1,  2,  3,  4,  5,106,  7,  7, 500,   6,754,854,  5,    904],
                        [4,   4,  5,104,  3,  2,  1,  1,  2,  3,  4,105,  6, 500,   7,756,856,  7,    906],
                        [5,   5,  4,  5,  6,  7,107,  6,  5,  4,  3,  2,  1, 500,   1,102,702,803,    903],
                        [6,   6,  7,  6,105,  4,  3,  2,  1,  1,  2,  3,104, 500,   5,757,857,  6,    907],
                        [7,   7,  6,  7,  7,106,  5,  4,  3,  2,  1,  1,  2, 500, 103,752,852,  4,    905]
                ],
                       d: true,
                       e: true
            ),
            MethodData(a: "Plain Bob Triples",
                       b: 7,
                       c: [
                        [1, 1,2,3,4,5,6,7,7,6,5,4,3,2,     500,  1,701,801,901],
                        [2, 102,1,1,2,3,4,5,6,107,7,6,5,4, 500,  3,703,802,904],
                        [3, 3,4,5,6,7,107,6,5,4,3,2,1,1,   500,102,702,803,902],
                        [4, 4,103,2,1,1,2,3,4,5,106,7,7,6, 500,  5,706,806,906],
                        [5, 5,6,7,7,106,5,4,3,2,1,1,2,103, 500,  4,704,804,903],
                        [6, 6,5,104,3,2,1,1,2,3,4,105,6,7, 500,  7,707,807,907],
                        [7, 7,7,6,105,4,3,2,1,1,2,3,104,5, 500,  6,705,805,905]
                ],
                       d: true,
                       e: true),
            MethodData(a: "Stedman Triples",
                       b: 7,
                       c: [
                        [1,  1,2,500,3,700,700, 4,5,4,5,4,500,5,757,857, 6,7,6, 907],
                        [4,  4,5,500,4,700,800, 3,3,2,1,1,500,2,700,800, 1,1,2, 903],
                        [3,  3,3,500,2,700,800, 1,2,3,3,2,500,1,700,800, 2,3,3, 902],
                        [2,  2,1,500,1,700,800, 2,1,1,2,3,500,3,700,800, 4,5,4, 905],
                        [5,  5,4,500,5,756,856, 6,7,6,7,6,500,7,700,851, 7,6,7, 906],
                        [6,  6,7,500,6,765,857 ,5,4,5,4,5,500,4,700,800, 3,2,1, 901],
                        [7,  7,6,500,7,700,855, 7,6,7,6,7,500,6,751,855, 5,4,5, 904]
                ],
                       d: true,
                       e: true)
        ],
        // Major methods.
        
        [
            MethodData(a: "Plain Hunt",
                       b: 8,
                       c: [
                        [1,   1,  2,  3,  4,  5,  6,  7,  8,  8,  7,  6,  5,  4,  3,  2,     901],
                        [2, 102,  1,  1,  2,  3,  4,  5,  6,  7,108,  8,  7,  6,  5,  4,  3, 902],
                        [3,   3,  4,  5,  6,  7,  8,108,  7,  6,  5,  4,  3,  2,  1,  1,102, 903],
                        [4,   4,103,  2,  1,  1,  2,  3,  4,  5,  6,107,  8,  8,  7,  6,  5, 904],
                        [5,   5,  6,  7,  8,  8,107,  6,  5,  4,  3,  2,  1,  1,  2,103,  4, 905],
                        [6,   6,  5,104,  3,  2,  1,  1,  2,  3,  4,  5,106,  7,  8,  8,  7, 906],
                        [7,   7,  8,  8,  7,106,  5,  4,  3,  2,  1,  1,  2,  3,104,  5,  6, 907],
                        [8,   8,  7,  6,105,  4,  3,  2,  1,  1,  2,  3,  4,105,  6,  7,  8, 908]
                ],
                       d: false,
                       e: false),
            
            MethodData(a: "Plain Bob Major",
                       b: 8,
                       c: [
                        [1,   1,  2,  3,  4,  5,  6,  7,  8,  8,  7,  6,  5,  4,  3,  2, 500,  1,701,801,901],
                        [2, 102,  1,  1,  2,  3,  4,  5,  6,  7,108,  8,  7,  6,  5,  4, 500,  3,703,802,904],
                        [3,   3,  4,  5,  6,  7,  8,108,  7,  6,  5,  4,  3,  2,  1,  1, 500,102,702,803,902],
                        [4,   4,103,  2,  1,  1,  2,  3,  4,  5,  6,107,  8,  8,  7,  8, 500,  7,706,806,906],
                        [5,   5,  6,  7,  8,  8,107,  6,  5,  4,  3,  2,  1,  1,  2,103, 500,  4,704,804,903],
                        [6,   6,  5,104,  3,  2,  1,  1,  2,  3,  4,  5,106,  7,  8,  8, 500,  7,707,807,907],
                        [7,   7,  8,  8,  7,106,  5,  4,  3,  2,  1,  1,  2,  3,104,  5, 500,  6,705,805,905],
                        [8,   8,  7,  6,105,  4,  3,  2,  1,  1,  2,  3,  4,105,  6,  7, 500,  8,707,807,907]
                ],
                       d: true,
                       e: true),
            MethodData(a: "Cambridge Surprise Major",
                       b: 8,
                       c: [
                        [1, 1,2,1,2,3,4,3,4,5,6,5,6,7,8,7,8,8,7,8,7,6,5,6,5,4,3,4,3,2,1,2,        500,  1,701,801,901],
                        [2, 102,1,102,1,1,2,2,1,2,1,1,2,1,2,3,4,3,4,5,6,107,8,107,8,7,8,8,7,8,7,6,500,  5,706,806,906],
                        [3, 3,4,5,6,5,6,7,8,7,8,7,8,108,7,108,7,7,108,7,108,8,7,8,7,8,7,6,5,6,5,4,500,  3,703,802,904],
                        [4, 4,103,3,4,104,3,104,3,3,4,4,3,4,3,2,1,2,1,1,2,1,2,3,4,105,6,7,8,7,8,8,500,  7,708,808,908],
                        [5, 5,6,7,8,7,8,8,7,8,107,8,107,6,5,4,3,4,3,2,1,2,1,1,2,1,2,2,1,1,102,1,  500,102,702,803,902],
                        [6, 6,5,4,103,2,1,1,2,1,2,3,4,3,4,5,6,5,6,6,5,5,106,5,106,6,5,105,6,5,6,7,500,  8,707,807,907],
                        [7, 7,8,8,7,8,7,6,105,4,3,2,1,2,1,1,2,1,2,3,4,3,4,4,3,3,104,3,104,4,3,103,500,  4,704,804,903],
                        [8, 8,7,6,5,6,105,5,6,106,5,106,5,5,6,6,5,6,5,4,3,4,3,2,1,2,1,1,2,103,4,5,500,  6,705,805,905]
                ],
                       d: true,
                       e: true)
        ]
        
    ]
    
    //--------------------------------------------------
    // Receive stage as number, return number of methods in that stage
    //--------------------------------------------------
    func methodCount(requestStage: Int) -> Int {
        let methodCount = methodList[requestStage].count
        print("methodCount: request", requestStage, "->", methodCount)
        return methodCount
    }
    
    //--------------------------------------------------
    // Receive stage as number, method as number, return name.
    //--------------------------------------------------
    func findName(requestStage: Int, requestRow: Int) -> String {
        let returnName = methodList[requestStage][requestRow].methodName
        print("findName: request", requestStage, requestRow, "->", returnName)
        return returnName
    }
    
    //--------------------------------------------------
    // Receive stage as number, method as number. Return bobvalid, singlevalid.
    //--------------------------------------------------
    func findValidCalls(requestStage: Int, requestRow: Int) -> (Bool, Bool) {
        let returnBob = methodList[requestStage][requestRow].bobValid
        let returnSingle = methodList[requestStage][requestRow].singleValid
        print("findValidCalls: request", requestStage, requestRow, "->", returnBob, returnSingle)
        return (returnBob, returnSingle)
    }
    
    //--------------------------------------------------
    // Receive stage as number, method as number, placebell. Return array of positions.
    //--------------------------------------------------
    func findBellArray(requestStage: Int, requestRow: Int, requestBell: Int) -> [Int] {
        
        let bellInArray = requestBell - 1
        let methodArray = methodList[requestStage][requestRow].methodArray[bellInArray]
        print("findBellArray: request", requestStage, requestRow, requestBell)
        return methodArray
    }
    
    //------------------------------------------------------------------------------------------------
    // Move on in map.
    //------------------------------------------------------------------------------------------------
    mutating func findNextPlace (requestStage: Int, requestRow: Int, requestArray: [Int], requestArrayIndex: Int, bobRequested: Bool, singleRequested: Bool) -> ([Int], Int, Bool, Bool) {
        // Return: Array, Array Pointer, Call started, Call ended.
        
        var nextBellFound = false
        var returnArray = requestArray
        var returnArrayIndex = requestArrayIndex
        var callStarted = false
        var callEnded = false
        //        mapPointer = re
        var newPlaceBell = 0
        //        workArray = requestArray
        
        
        while nextBellFound == false {
            
            returnArrayIndex = returnArrayIndex + 1
            var nextPlaceNumber = returnArray[returnArrayIndex]
            print("findNextPlace - Start SWITCH for moving on in array...", nextPlaceNumber)
            
            //----------------------
            switch nextPlaceNumber {
                
            // 9nn - move to new array, at the start of it.
            case _ where (nextPlaceNumber > 900
                || ((nextPlaceNumber < 900 && nextPlaceNumber > 800) && bobRequested == true)
                || ((nextPlaceNumber < 800 && nextPlaceNumber > 700) && singleRequested == true)
                ):
                newPlaceBell = nextPlaceNumber - ((nextPlaceNumber / 100) * 100)
                if newPlaceBell > 50 {
                    newPlaceBell = newPlaceBell - 50
                } else {
                    returnArrayIndex = 1
                    callEnded = true
                    print("findNextPlace - 'Call Ended' set.")
                }
                (returnArray) = findBellArray(requestStage: requestStage, requestRow: requestRow, requestBell: newPlaceBell)
                
                //                workArray = nextArray
                print("findNextPlace - End of place bell, new place bell is", newPlaceBell)
                
                nextPlaceNumber = returnArray[returnArrayIndex]
                
                if nextPlaceNumber < 200 {
                    nextBellFound = true
                }
                
                
            // Check for BOB/SINGLE to be announced.
            case _ where nextPlaceNumber == 500:
                if (bobRequested == true || singleRequested == true) {
                    print("findNextPlace - Code 500 and Call active.")
                    callStarted = true
                } else {
                    print("findNextPlace - Bypass BOB/SINGLE call.")
                }
                
            // 700/800 - dummy end of call.
            case _ where (nextPlaceNumber == 800 && bobRequested == true):
                print("findnextPlace - dummy end of BOB")
                callEnded = true
            case _ where (nextPlaceNumber == 700 && singleRequested == true):
                print("findnextPlace - dummy end of SINGLE")
                callEnded = true
                
            // Zero is a dummy filler.
            case 0:
                print("findNextPlace - dummy filler.")
                
                
                
            default:
                print("findNextPlace - DEFAULT process, nextPlaceNumber is", nextPlaceNumber)
                if nextPlaceNumber < 200 {
                    nextBellFound = true
                    newPlaceBell = nextPlaceNumber
                }
            }
        }
        print("findNextPlace - return", returnArray , returnArrayIndex, callStarted, callEnded)
        
        return (returnArray, returnArrayIndex, callStarted, callEnded)
    }
}
