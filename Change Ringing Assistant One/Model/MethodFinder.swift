//
//  MethodFinder.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 30/04/2020.
//  Copyright © 2020 Ray Price. All rights reserved.
//

import Foundation

struct MethodFinder {
	
	var stageFinder = StageFinder()
	
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
	
	var placeBellData = [
		//Minimus
		[
			PlaceBellData(a: "Plain Hunt", b: "x1x1x1x1", c: [0], d: [0]),
			PlaceBellData(a: "Plain Bob", b: "x4x4x4x2", c: [0], d: [0]),
			PlaceBellData(a: "Reverse Bob", b: "&-1-3,14", c: [0], d: [0])
		],
		//Doubles.
		[
			//			PlaceBellData(a: "Grandsire Doubles", b: "+1.5.1.5.1", c: [10,9,3], d: [10,9,3,123]),
			
			PlaceBellData(a: "Plain Hunt", b: "5.1.5.1.5.1.5.1.5.1", c: [0], d: [0]),
			PlaceBellData(a: "Plain Bob", b: "&5.1.5.1.5,25", c: [10,0,145], d: [0]),
			PlaceBellData(a: "Reverse Bob"),
			
			PlaceBellData(a: "St Simon's Bob", b: "&5.1.5.3.5,25", c: [10,0,145], d: [0]),
			PlaceBellData(a: "St Martin's Bob", b: "&5.1.5.23.5,25", c: [10,0,145], d: [0]),
//			PlaceBellData(a: "Grandsire Doubles", b: "+3.1.5.1.5.1.5.1.5.1", c: [10,9,3], d: [10,9,3,123]),

			PlaceBellData(a: "Grandsire", b: "&3,1.5.1.5.1", c: [10,9,3], d: [10,9,3,123]),
			PlaceBellData(a: "Stedman", b: "3.1.5.3.1.3.1.3.5.1.3.1", c: [0], d: [6,0,345])
		],
		// Minor
		[
			PlaceBellData(a: "Plain Hunt", b: "x6x6x6x6x6x6", c: [0], d: [0]),
			PlaceBellData(a: "Plain Bob", b: "a x1x1x1x1x1x.12", c: [12,0,14], d: [12,0,1234]),
			PlaceBellData(a: "St Clement's College Bob"),
			PlaceBellData(a: "Cambridge Surprise"), //b: "b -3-4-2-3-4-5-4-3-2-4-3-12", c: [24,0,14], d: [24,1,1234]),
			PlaceBellData(a: "Beverley Surprise"), //b: "&-36-14-12-36.14-34.56,12", c: [24,0,14], d: [24,0,1234]),
			PlaceBellData(a: "Bourne Surprise"), //b: "&-3-4-2-3-34-3,12", c: [24,0,14], d: [24,0,1234]),
			PlaceBellData(a: "London Surprise", c: [24,0,56], d: [24,0,1256])
		],
		// Triples
		[
			PlaceBellData(a: "Plain Hunt", b: "x17x17x17x17x17x17x17", c: [0], d: [0]),
			PlaceBellData(a: "Grandsire", b: "+3.1.7.1.7.1.7.1.7.1.7.1.7.1", c: [14,13,3], d: [14,13,3,123]),
			PlaceBellData(a: "Plain Bob", b: "&7.1.7.1.7.1.7,2", c: [14,0,14], d: [14,0,1234]),
			PlaceBellData(a: "Single Oxford Bob"),
			PlaceBellData(a: "St Clement's College Bob"),
			PlaceBellData(a: "Stedman", b: "&3.1.7.3.1.3.1.3.7.1.3.1", c: [6,3,5], d: [6,3,567])
		],
		// Major
		[
			PlaceBellData(a: "Plain Hunt", b: "x18x18x18x18x18x18x18x18", c: [0], d: [0]),
			PlaceBellData(a: "Plain Bob", b: "&-1-1-1-1,2", c: [16,0,14], d: [16,0,1234]),
			PlaceBellData(a: "Cambridge Surprise", b: "&-38-4-258-36-4-58-6-78,2", c: [32,0,12], d: [32,0,1234])
		]
	]
	
	mutating func extractXMLData(cccbrData: [CCCBRData]) {
		
		print("++++++++++extractXMLData++++++++++")
		
		var tempPlaceBellCode: String
		var tempBobArray: [Int]
		var tempSingleArray: [Int]
		var stageName: String
		for i in 0..<placeBellData.count {
			stageName = stageFinder.findStageName(requestStage: i)
				for j in 0..<placeBellData[i].count {

// See if all data present. "Symmetry" only needed if other data missing.
					// placeBellData[i][j].methodSymmetry == nil
				if ( placeBellData[i][j].placeBellCode == nil || placeBellData[i][j].bobArray == nil || placeBellData[i][j].singleArray == nil) {
					let fullName = placeBellData[i][j].methodName.lowercased() + " " + stageName.lowercased()
//					print(fullName)
					let xmlIndex = cccbrData.firstIndex(where: { $0.cccbrTitle.lowercased() == fullName})
//						placeBellData[i][j].methodName.lowercased()})
					if xmlIndex != nil {
						print("Extracting details for", placeBellData[i][j].methodName, stageName) //, "from", cccbrData[xmlIndex!])
						
						if placeBellData[i][j].methodSymmetry == nil {
							placeBellData[i][j].methodSymmetry = cccbrData[xmlIndex!].cccbrSymmetry
						}
						
						if placeBellData[i][j].placeBellCode == nil {
							tempPlaceBellCode = cccbrData[xmlIndex!].cccbrNotation
							if cccbrData[xmlIndex!].cccbrSymmetry == "palindromic" {
								tempPlaceBellCode = "&" + tempPlaceBellCode
								placeBellData[i][j].placeBellCode = tempPlaceBellCode
							}
						}
						
						if placeBellData[i][j].bobArray == nil {
							let tempLOLB = Int(cccbrData[xmlIndex!].cccbrLengthOfLead)!
							switch cccbrData[xmlIndex!].cccbrNumberOfHunts {
							case "1":
								tempBobArray = [tempLOLB, 0, 14]
							case "2":
								tempBobArray = [tempLOLB, tempLOLB - 1, 3]
							default:
								tempBobArray = [0]
							}
							placeBellData[i][j].bobArray = tempBobArray
							
						}
						
						if placeBellData[i][j].singleArray == nil {
							let tempLOLS = Int(cccbrData[xmlIndex!].cccbrLengthOfLead)!
							switch cccbrData[xmlIndex!].cccbrNumberOfHunts {
							case "1":
								tempSingleArray = [tempLOLS, 0, 14]
							case "2":
								tempSingleArray = [tempLOLS, tempLOLS - 1, 3, 123]
							default:
								tempSingleArray = [0]
							}
							placeBellData[i][j].singleArray = tempSingleArray
						}
						
//						print(placeBellData[i][j].placeBellCode as Any, placeBellData[i][j].bobArray as Any, placeBellData[i][j].singleArray as Any)
						
					} else {
						print("!!!!!method not found in XML :", placeBellData[i][j].methodName, stageName)
					}
				}
			}
		}
		print("----------extractXMLData----------")
	}
	
	
	
	
	
	
	//--------------------------------------------------
	// Receive stage as number, return number of methods in that stage
	//--------------------------------------------------
	func methodCount(requestStage: Int) -> Int {
		let methodCount = placeBellData[requestStage].count
		return methodCount
	}
	
	//--------------------------------------------------
	// Receive stage as number, method as number, return name.
	//--------------------------------------------------
	func findName(requestStage: Int, requestRow: Int) -> String {
		let returnName = String(placeBellData[requestStage][requestRow].methodName)
		return returnName
	}
	
	//--------------------------------------------------
	// Receive stage as number, method as number. Return method data as MethodData streucture.
	//--------------------------------------------------
	
	func findMethodData(requestStage: Int, requestRow: Int) -> MethodData {
		var returnMethodData: MethodData = MethodData(a: "", b: 0, c: "", d: [[0],[0],[0]], e: false, f: false)
		returnMethodData.methodName = findName(requestStage: requestStage, requestRow: requestRow)
		returnMethodData.bellCount = stageFinder.findStageBells(requestStage: requestStage)
		returnMethodData.methodStructure = placeBellData[requestStage][requestRow].placeBellCode!

		returnMethodData.methodArray[0] = convertPlaceBell(methodStructure: placeBellData[requestStage][requestRow].placeBellCode!)
		returnMethodData.methodArray[1] = placeBellData[requestStage][requestRow].bobArray!
		returnMethodData.methodArray[2] = placeBellData[requestStage][requestRow].singleArray!
		
		
		(returnMethodData.bobValid, returnMethodData.singleValid) = findValidCalls(requestStage: requestStage, requestRow: requestRow)
		
		print("findMethodData:", returnMethodData)

		return returnMethodData
	}
	
	//--------------------------------------------------
	// Convert standard format method place bell code to array.
	//--------------------------------------------------
	func convertPlaceBell(methodStructure: String) -> [Int] {
		var tempStructure: String = methodStructure
		var workStructure: String
		var work1: String
//		var symmetry: Bool = false
		var converted: [Int] = []
		let numbers = CharacterSet(charactersIn: "0123456789")
		var newChangeFound: Bool = true
		var bellsAdded: Int = 0
//		var foundComma: Bool = false
		var foundDotOrX: Bool = false
		var foundAnd: Bool = false
		var nonSymmetryCount: Int = 0
		var xxx: Int = 0 // Safety net, prevent endless loop.
		
		repeat {
			work1 = String(tempStructure.prefix(1))
			//    break
			switch work1 {
			case _ where (work1 == "&"):
				foundAnd = true
				tempStructure = String(tempStructure.suffix(tempStructure.count - 1))
			case _ where work1 == "+":
				tempStructure = String(tempStructure.suffix(tempStructure.count - 1))
				
			case _ where work1 == "," :
//				foundComma = true
				if !foundDotOrX {
					tempStructure = String(tempStructure.suffix(tempStructure.count - 1))

					if foundAnd {
						tempStructure += ","
						nonSymmetryCount = converted.count
						
					}
				} else {
					
					tempStructure = String(tempStructure.suffix(tempStructure.count - 1))
					
					let j = converted.count - 2
										
					for i in (nonSymmetryCount...j).reversed() {
						converted.append(converted[i])
					}
					nonSymmetryCount = 0

				}
				
			case _ where (work1 == "." || work1 == " "):
				foundDotOrX = true
				newChangeFound = true
				tempStructure = String(tempStructure.suffix(tempStructure.count - 1))
				
			case _ where (work1 == "x" || work1 == "-"):
				foundDotOrX = true
				newChangeFound = true
				converted.append(0)
				tempStructure = String(tempStructure.suffix(tempStructure.count - 1))
				
			case _ where (work1.rangeOfCharacter(from: numbers.inverted) != nil):
				tempStructure = String(tempStructure.suffix(tempStructure.count - 1))
				
				
			// If this point is reached, a number has been found.
			default:
				
				workStructure = tempStructure
				if newChangeFound {
					let workInt = Int(work1)!
					if ((workInt / 2) * 2) == workInt {
						workStructure = "1" + workStructure
						bellsAdded += 1
						newChangeFound = false
					}
				}
				
				while (workStructure.rangeOfCharacter(from: numbers.inverted) != nil) {
					workStructure = String(workStructure.prefix(workStructure.count - 1))
				}
				converted.append(Int(workStructure)!)
				tempStructure = String(tempStructure.suffix(tempStructure.count - workStructure.count + bellsAdded))
				bellsAdded = 0
				//                }
			}
			
			if tempStructure.count == 0 {
				break
			}
			
			xxx += 1
			if xxx > 49 {
				print(">>>>>>>>>>>>>>>>>>>>>>loop break forced<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
				break
			}
			
		} while xxx < 50
		
//		print("Converted array: ---------->", converted)
		return converted
	}
	
	//--------------------------------------------------
	// Receive stage as number, method as number. Return bobvalid, singlevalid.
	//--------------------------------------------------
	func findValidCalls(requestStage: Int, requestRow: Int) -> (Bool, Bool) {
		var returnBobValid = false
		if placeBellData[requestStage][requestRow].bobArray!.count > 1 {
			returnBobValid = true
		}
		var returnSingleValid = false
		if placeBellData[requestStage][requestRow].singleArray!.count > 1 {
			returnSingleValid = true
		}
		return (returnBobValid, returnSingleValid)
	}
	
	
	//------------------------------------------------------------------------------------------------
	// Find next correct bell.
	// Receive: MethodArray.
	//          User bell number.
	//          Current bell position. e.g. 1 = lead
	//          Change number.
	//          Current sequence of bells, e.g. rounds = 12345678.
	//          Current place bell.
	// Return:  Method array, amended        -> returnMethodArray
	//          Next position for user bell. -> returnBellPosition
	//          Flag if treble is in front.  -> returnFollowsTreble
	//          New sequence of bells.       -> returnBellSequence
	//          New place bell               -> returnPlaceBell - zero if no change.
	//          Call started                 -> returnCallStarted - true if call begins.
	//------------------------------------------------------------------------------------------------
	func findNextPosition(currentMethodArray: [[Int]],
						  currentUserBell: Int,
						  currentBellPosition: Int,
						  currentChangeNumber: Int,
						  currentBellSequence: String,
						  currentPlaceBell: Int,
						  bobRequested: Bool,
						  singleRequested: Bool) -> ([[Int]], Int, Bool, String, Int, Bool) {
		
		
		let newPlaceCode = currentMethodArray[0][currentChangeNumber]
		print("----------findNextPosition----------")
		print("newplacecode", newPlaceCode, "currentMethodArray", currentMethodArray, "currentUserBell", currentUserBell, "currentBellPosition", currentBellPosition, "currentChangeNumber", currentChangeNumber, "currentBellSequence", currentBellSequence, "currentPlaceBell", currentPlaceBell,"bob", bobRequested, "singler", singleRequested)
		let stringPlaceCode = String(newPlaceCode)
		var returnBellSequence = currentBellSequence
		var returnPlaceBell: Int = 0
		
		var returnMethodArray = currentMethodArray
		var returnBellPosition: Int = currentBellPosition
		var returnFollowsTreble: Bool = false
		var returnCallStarted: Bool = false
		
		var ix: Int = 1
		
		repeat {
			let index1 = returnBellSequence.index(returnBellSequence.startIndex, offsetBy: ix - 1)
			let index2 = returnBellSequence.index(returnBellSequence.startIndex, offsetBy: ix)
			let save1 = returnBellSequence.prefix(ix - 1)
			if stringPlaceCode.contains(String(ix)) {
				if ix == currentBellPosition {
					if save1.suffix(1) == "1" {
						returnFollowsTreble = true
					}
				}
				ix = ix + 1
			} else {
				if ix < returnBellSequence.count {
					let save2 = returnBellSequence[index1...index1]
					let save3 = returnBellSequence[index2...index2]
					let save4 = returnBellSequence.suffix(returnBellSequence.count - ix - 1)
					print("save1234", save1, save2, save3, save4)
					
					returnBellSequence = String(save1 + save3 + save2 + save4)
					
					
					if ix == currentBellPosition {
						returnBellPosition = currentBellPosition + 1
						if save3 == "1" {
							returnFollowsTreble = true
						}
						
					}
					if ix + 1 == currentBellPosition {
						returnBellPosition = currentBellPosition - 1
						if save1.suffix(1) == "1" {
							returnFollowsTreble = true
						}
						
					}
				}
				ix = ix + 2
				
			}
		} while ix <= returnBellSequence.count
		
		// Check for final change in array, which implies a new place bell.
		
		if currentChangeNumber == currentMethodArray[0].count - 1 {
			returnPlaceBell = returnBellPosition
		}
		
		// See if a bob or single can be called after the current change.
		if bobRequested {
			let bobArray = currentMethodArray[1]
			let bobCallFrequency = bobArray[0]
			var bobCallFirst = bobArray[1] - 3
			if bobCallFirst < 0 {
				bobCallFirst = bobCallFirst + bobCallFrequency
			}
			print("Bob call?", returnMethodArray[0], currentChangeNumber, bobCallFirst, bobCallFrequency)
			if (currentChangeNumber == bobCallFirst || currentChangeNumber == bobCallFirst + bobCallFrequency) {
				returnCallStarted = true
				
				for i in 1...returnMethodArray[1].count - 2 {
					returnMethodArray[0][currentChangeNumber + i + 1] = returnMethodArray[1][i + 1]
					//                    print("-------->", returnMethodArray[0])
				}
			}
		}
		
		if singleRequested {
			let singleArray = currentMethodArray[2]
			let singleCallFrequency = singleArray[0]
			var singleCallFirst = singleArray[1] - 3
			if singleCallFirst < 0 {
				singleCallFirst = singleCallFirst + singleCallFrequency
			}
			print("SINGLE call?", returnMethodArray[0], currentChangeNumber, singleCallFirst, singleCallFrequency)
			if (currentChangeNumber == singleCallFirst || currentChangeNumber == singleCallFirst + singleCallFrequency) {
				returnCallStarted = true
				
				for i in 1...returnMethodArray[2].count - 2 {
					returnMethodArray[0][currentChangeNumber + i + 1] = returnMethodArray[2][i + 1]
					print("----------->", returnMethodArray[0])
				}
			}
		}
		print("return",returnMethodArray, returnBellPosition, returnFollowsTreble, returnBellSequence, returnPlaceBell, returnCallStarted)
		print("----------findNextPosition----------")

		
		return (returnMethodArray, returnBellPosition, returnFollowsTreble, returnBellSequence, returnPlaceBell, returnCallStarted)
		
	}
	
}
