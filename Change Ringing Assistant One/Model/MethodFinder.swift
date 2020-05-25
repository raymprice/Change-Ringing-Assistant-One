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
	var placeBellData: [[PlaceBellData]] = [[],[],[],[],[]]
	
	//--------------------------------------------------
	// Use CCCBR XML data to populate array of method data.
	//--------------------------------------------------
	
	mutating func extractXMLData(cccbrData: [CCCBRData]) {
		
		readMethodList()
		
		print("++++++++++extractXMLData++++++++++")
		
		var tempPlaceBellCode: String
		var tempBobArray: [Int]
		var tempSingleArray: [Int]
		var stageName: String
		
		for i in 0..<placeBellData.count {
			stageName = stageFinder.findStageName(requestStage: i)
//			print("count", placeBellData[i].count)
//			print("i", i)

			var ixCount: Int = 0
			var placeBellDataCount = placeBellData[i].count
			repeat {
//				print("ixCount", ixCount)
				// See if all data present. "Symmetry" only needed if other data missing.
				// placeBellData[i][j].methodSymmetry == nil
				if ( placeBellData[i][ixCount].placeBellCode == nil || placeBellData[i][ixCount].bobArray == nil || placeBellData[i][ixCount].singleArray == nil) {
					let fullName = placeBellData[i][ixCount].methodName.lowercased() + " " + stageName.lowercased()
//					print(fullName)
					let xmlIndex = cccbrData.firstIndex(where: { $0.cccbrTitle.lowercased() == fullName})
					//						placeBellData[i][j].methodName.lowercased()})
					if xmlIndex != nil {
						print("Extracting details for", placeBellData[i][ixCount].methodName, stageName) //, "from", cccbrData[xmlIndex!])
						if placeBellData[i][ixCount].methodSymmetry == nil {
							placeBellData[i][ixCount].methodSymmetry = cccbrData[xmlIndex!].cccbrSymmetry
						}
						
						if placeBellData[i][ixCount].placeBellCode == nil {
							tempPlaceBellCode = cccbrData[xmlIndex!].cccbrNotation
							if cccbrData[xmlIndex!].cccbrSymmetry == "palindromic" {
								tempPlaceBellCode = "&" + tempPlaceBellCode
								placeBellData[i][ixCount].placeBellCode = tempPlaceBellCode
							}
						}
						if placeBellData[i][ixCount].bobArray == nil {
							let tempLOLB = Int(cccbrData[xmlIndex!].cccbrLengthOfLead)!
							switch cccbrData[xmlIndex!].cccbrNumberOfHunts {
							case "1":
								tempBobArray = [tempLOLB, 0, 14]
							case "2":
								tempBobArray = [tempLOLB, tempLOLB - 1, 3]
							default:
								tempBobArray = [0]
							}
							placeBellData[i][ixCount].bobArray = tempBobArray
						}
						if placeBellData[i][ixCount].singleArray == nil {
							let tempLOLS = Int(cccbrData[xmlIndex!].cccbrLengthOfLead)!
							switch cccbrData[xmlIndex!].cccbrNumberOfHunts {
							case "1":
								tempSingleArray = [tempLOLS, 0, 14]
							case "2":
								tempSingleArray = [tempLOLS, tempLOLS - 1, 3, 123]
							default:
								tempSingleArray = [0]
							}
							placeBellData[i][ixCount].singleArray = tempSingleArray
						}
						//						print(placeBellData[i][j].placeBellCode as Any, placeBellData[i][j].bobArray as Any, placeBellData[i][j].singleArray as Any)
						ixCount += 1
					} else {
//						print(placeBellData[i].count)
						print("!!!!!method not found in XML :", placeBellData[i][ixCount].methodName, stageName)
						placeBellData[i].remove(at: ixCount)
//						print(placeBellData[i].count)
//						ixCount = ixCount - 1
					}
				} else {
					print("No XML data needed for", placeBellData[i][ixCount].methodName, stageName)
					ixCount += 1
				}
				placeBellDataCount -= 1
			} while placeBellDataCount > 0
		}
		print("----------extractXMLData----------")
	}
	
	//--------------------------------------------------
	// Read file of method names and defaults, store in array.
	//--------------------------------------------------
	mutating func readMethodList() {
		var inputMethodFile: String = ""
		var inputStageName: String = ""
		var methodForArray: String = ""
		var notationForArray: String? = nil
		var bobForArray: [Int]? = nil
		var singleForArray: [Int]? = nil
		var symmetryForArray: String? = nil
		print("++++++++++readMethodList++++++++++")
		
		if let path = Bundle.main.url(forResource: "MethodList", withExtension: "txt") {
			do {
				inputMethodFile = try String(contentsOf: path)
			} catch {
				print("ERROR")
			}
			
//			print("inputMethodFile", inputMethodFile)
			let inputLines = inputMethodFile.split(separator: "\n")
			for inputLine in inputLines {
				if inputLine.prefix(1) == "*" {  // Ignore comments.
					print("Comment", inputLine)
					continue
				}
				methodForArray = ""
//				print("inputLine", inputLine)
				var inputItems = inputLine.split(separator: ";", omittingEmptySubsequences: false)
//				print("original inputItems", inputItems)
				
				let methodWords = inputItems[0].split(separator: " ")
//				print("methodWords", methodWords, methodWords.count)
				for ix in 0..<methodWords.count {
					if ix == methodWords.count - 1 {
						inputStageName = String(methodWords[ix])
					} else {
						methodForArray = methodForArray + methodWords[ix] + " "
					}
				}
				let firstLetter = inputStageName.prefix(1).uppercased()
				inputStageName = firstLetter + inputStageName.suffix(inputStageName.count - 1)
//				print("Stage", inputStageName)
//				print("methodForArray", methodForArray, methodForArray.count)
				methodForArray = methodForArray.trimmingCharacters(in: .whitespaces)
//				print("methodForArray", methodForArray, methodForArray.count)
				if inputItems.count < 5 {
					for _ in 1...(5 - inputItems.count) {
						inputItems.append("")
					}
				}
//				print("modified inputItems", inputItems)
				notationForArray = String(inputItems[1])
				if inputItems[1] == "" {
					notationForArray = nil
				}
				bobForArray = nil
				if inputItems[2] != "" {
					bobForArray = splitCallData(callData: String(inputItems[2]))
				}
				singleForArray = nil
				if inputItems[3] != "" {
					singleForArray = splitCallData(callData: String(inputItems[3]))
				}
				symmetryForArray = nil
				if inputItems[4] != "" {
					symmetryForArray = String(inputItems[4])
				}
				//				print("Array", methodForArray, notationForArray ?? "?", bobForArray ?? [99], singleForArray ?? [99], symmetryForArray ?? "?")
				let arrayObject: PlaceBellData = PlaceBellData(a: methodForArray, b: notationForArray, c: bobForArray, d: singleForArray, e: symmetryForArray)
				let stageIndex = stageFinder.findStageIndex(requestStage: inputStageName)
				placeBellData[stageIndex].append(arrayObject)
			}
		}
//		print("placeBellData.count", placeBellData.count)
		for i in 0..<placeBellData.count {
//			print("Before", placeBellData[i])
			placeBellData[i].sort{$0.methodName < $1.methodName}
//			print("After" , placeBellData[i])
		}
		print("----------readMethodList----------")
	}
	
	//--------------------------------------------------
	// Split String reprsentation of Array into actual Integer Array.
	//--------------------------------------------------
	func splitCallData(callData: String) -> [Int] {
		var returnArray: [Int] = []
//		print("splitCallData", callData)
		var itembit = callData.suffix(callData.count - 1)
		itembit = itembit.prefix(itembit.count - 1)
//		print(itembit)
		let bits = itembit.split(separator: ",")
		for bit in bits {
//			print("bit", bit)
			let bitInt = Int(bit)
//			print(bitInt ?? 0)
			returnArray.append(bitInt ?? 0)
		}
		return returnArray
	}
	
	//--------------------------------------------------
	// Receive stage as number, return number of methods in that stage
	//--------------------------------------------------
	func methodCount(requestStage: Int) -> Int {
		let methodCount = placeBellData[requestStage].count
		return methodCount
	}
	
	//--------------------------------------------------
	// Receive stage as number, method name as string, return reference number of method in that stage
	//--------------------------------------------------
	func methodNameSearch(requestStage: Int, requestName: String) -> Int {
		let returnIX = placeBellData[requestStage].firstIndex(where: { $0.methodName == requestName }) ?? -1
		print("methodNameSearch:", requestStage, requestName, returnIX)
		return returnIX
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
// methodStructure done in samll bits because compiler couldn't handle one large statememnt!!!
		let s1 = placeBellData[requestStage][requestRow].placeBellCode ?? "?"
		let s2a = placeBellData[requestStage][requestRow].bobArray ?? [0]
		let s2 = s2a.map(String.init).joined(separator: ",")
		let s3a = placeBellData[requestStage][requestRow].singleArray ?? [0]
		let s3 = s3a.map(String.init).joined(separator: ",")
		returnMethodData.methodStructure = s1 + " B[" + s2 + "] S[" + s3 + "]"
//		print(returnMethodData.methodStructure)
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
		var converted: [Int] = []
		let numbers = CharacterSet(charactersIn: "0123456789")
		var newChangeFound: Bool = true
		var bellsAdded: Int = 0
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
		print("++++++++++findNextPosition++++++++++")
		print("newplacecode", newPlaceCode, "currentMethodArray", currentMethodArray, "currentUserBell", currentUserBell, "currentBellPosition", currentBellPosition, "currentChangeNumber", currentChangeNumber, "currentBellSequence", currentBellSequence, "currentPlaceBell", currentPlaceBell,"bob", bobRequested, "singler", singleRequested)
		let stringPlaceCode = String(newPlaceCode)
		let stringUserBell = String(currentUserBell)
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
					print("save1324", save1, save3, save2, save4)
					returnBellSequence = String(save1 + save3 + save2 + save4)
					
					if ix == currentBellPosition {
						returnBellPosition = currentBellPosition + 1
//						if save3 == "1" {
//							returnFollowsTreble = true
//						}
					}
					if ix + 1 == currentBellPosition {
						returnBellPosition = currentBellPosition - 1
//						if save1.suffix(1) == "1" {
//							returnFollowsTreble = true
//						}
					}
				}
				ix = ix + 2
			}
		} while ix <= returnBellSequence.count
		
		let ix1 = returnBellSequence.firstIndex(of: "1") ?? returnBellSequence.endIndex
		let work1 = returnBellSequence.suffix(from: ix1)
		let work2 = work1.suffix(work1.count - 1)
		if stringUserBell == work2.prefix(1) {
			returnFollowsTreble = true
		}
		
		
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
//			print("Bob call?", returnMethodArray[0], currentChangeNumber, bobCallFirst, bobCallFrequency)
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
//			print("SINGLE call?", returnMethodArray[0], currentChangeNumber, singleCallFirst, singleCallFrequency)
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
