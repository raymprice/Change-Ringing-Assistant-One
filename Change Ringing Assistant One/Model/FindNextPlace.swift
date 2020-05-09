//
//  FindNextPlace.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 01/05/2020.
//  Copyright © 2020 Ray Price. All rights reserved.
//
/******
import Foundation

var nextBellFound: Bool = false
var mapPointer: Int = 0
var nextPlaceNumber: Int = 0
var newPlaceBell: Int = 0
var bellCount: Int = 0
var nextArray: [Int] = [0,1,2]
var bobValid:Bool = false
var singleValid: Bool = false

func findNextPlace (currentMethod: Int, currentArray: [Int], currentPointer: Int) -> (Int, [Int]) {
//------------------------------------------------------------------------------------------------
        // Move on in map.
        
        nextBellFound = false
        
        while nextBellFound == false {
            
            mapPointer = mapPointer + 1
            nextPlaceNumber = currentArray[mapPointer]
            print("Start SWITCH for moving on in array...", nextPlaceNumber)
            
            switch nextPlaceNumber {
                
            // If end of array, move to new place bell.
            case _ where nextPlaceNumber > 900:
                newPlaceBell = nextPlaceNumber - 900
//                nextPlaceNumber = 0
                (currentMethod, bellCount, nextArray, bobValid, singleValid) = methodFinder.findMethod(requestSeq: currentMethod, placeBell: newPlaceBell)
                mapPointer = 1
                nextBellFound = true
                print("End of place bell, new place bell is", currentPlaceBell)

            // Check if bob/single point has been reached, but only if request active.
            //
            case _ where nextPlaceNumber > 800:
                if bobRequested == true {
                    print("Bob processing...")
                    currentPlaceBell = nextPlaceNumber - 800
//                    nextPlaceNumber = 0
                    (methodName, bellCount, placeBellArray, bobValid, singleValid) = methodFinder.findMethod(requestSeq: selectedMethod, placeBell: currentPlaceBell)
                    mapPointer = 1
                    
                    nextBellFound = true
                    bobRequested = false
                    bobButton.backgroundColor = UIColor.clear
                    print("End of bob processing, new place bell is", currentPlaceBell)

                } else {
                    print("Bob found, but no action requested.")
                }
                
            case _ where nextPlaceNumber > 700:
                if singleRequested == true {
                    print("Single processing...")
                    currentPlaceBell = nextPlaceNumber - 700
//                    nextPlaceNumber = 0
                    (methodName, bellCount, placeBellArray, bobValid, singleValid) = methodFinder.findMethod(requestSeq: selectedMethod, placeBell: currentPlaceBell)
                    mapPointer = 1
                    
                    nextBellFound = true
                    singleRequested = false
                    singleButton.backgroundColor = UIColor.clear
                    print("End of single processing, new place bell is", currentPlaceBell)

                } else {
                    print("Single found, but no action requested.")
                }
            case _ where nextPlaceNumber == 601:
                // Call BOB if required.
                if bobRequested == true {
                    print("Code 601 and Bob active.")
                    let url1 = Bundle.main.url(forResource: "bob", withExtension: "mp3")
                    player = try! AVAudioPlayer(contentsOf: url1!)
                    player.play()
                }
            case _ where nextPlaceNumber == 602:
                // Call SINGLE if required.
                if singleRequested == true {
                    print("Code 602 and Single active.")
                    let url1 = Bundle.main.url(forResource: "single", withExtension: "mp3")
                    player = try! AVAudioPlayer(contentsOf: url1!)
                    player.play()
                }
            default:
                print("DEFAULT process, nextPlaceNumber is", nextPlaceNumber)
                if nextPlaceNumber < 200 {
                    nextBellFound = true
                }
            }
        }
}
*****/
