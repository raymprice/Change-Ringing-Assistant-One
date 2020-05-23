//
//  ViewController.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 23/11/2017.
//  Copyright © 2017 Ray Price. All rights reserved.
//

import UIKit
import AVFoundation


struct CCCBRData {
	var cccbrTitle: String
	var cccbrStage: String
	var cccbrClassification: String
	var cccbrLengthOfLead: String
	var cccbrNumberOfHunts: String
	var cccbrNotation: String
	var cccbrSymmetry: String
	var cccbrLeadHeadCode: String
}

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, XMLParserDelegate{
	
	var cccbrMethods: [CCCBRData] = []
	var elementName: String = String()
	var xmlTitle = String()
	var xmlStage = String()
	var xmlClassification = String()
	var xmlLengthOfLead = String()
	var xmlNumberOfHunts = String()
	var xmlNotation = String()
	var xmlSymmetry = String()
	var xmlLeadHeadCode = String()
	
	var xmlMethodOrSet = String()
	
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: { context in
			self.setOrientation()
		})
	}
	
	func setOrientation() {
		if UIApplication.shared.statusBarOrientation.isLandscape {
			print("Landscape")
			self.followTreble.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
			self.followTreble.setTitle("Follow\nTreble:", for: .normal)
		} else {
			print("Portrait")
			self.followTreble.setTitle("F-T:", for: .normal)
		}
	}
	
	var player: AVAudioPlayer!
	var methodFinder = MethodFinder()
	var stageFinder = StageFinder()
	
	@IBOutlet weak var pickerView: UIPickerView!
	
	
	// Functions to handle pickerview.
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var returnRowsInComponent: Int
		//		print("++++++++++numberOfRowsInComponent++++++++++")
		if component == 1 {
			let tempStage = pickerView.selectedRow(inComponent: 1)
			returnRowsInComponent = stageFinder.findStageCount(requestStage: tempStage)
		} else {
			//			let currentStage = pickerView.selectedRow(inComponent: 1)
			returnRowsInComponent = methodFinder.methodCount(requestStage: currentPVStage)
		}
		//		print("numberOfRowsInComponent:", component, returnRowsInComponent)
		//		print("----------numberOfRowsInComponent----------")
		
		return returnRowsInComponent
		
	}
	
	//	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
	//		if component == 1 {
	//			let returnStageName = stageFinder.findStageName(requestStage: row)
	//			//            print("titleForRow:", component, row, "->", returnStageName)
	//			return returnStageName
	//		} else {
	//			let currentStage = pickerView.selectedRow(inComponent: 1)
	//
	//			let returnMethodName = methodFinder.findName(requestStage: currentStage, requestRow: row)
	//			//            print("titleForRow:", component, row, "->", returnMethodName)
	//			return returnMethodName
	//		}
	//
	//	}
	
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var pickerLabel: UILabel? = (view as? UILabel)
		if pickerLabel == nil {
			pickerLabel = UILabel()
			
			if component == 1 {
				
				//		pickerLabel?.font = UIFont.systemFont(ofSize: 20.0)
				pickerLabel?.textAlignment = .left
				
				
				pickerLabel?.text = stageFinder.findStageName(requestStage: row)
				//		  pickerLabel?.textColor = UIColor.red
			} else {
				let tempStage = pickerView.selectedRow(inComponent: 1)
				
				//		pickerLabel?.font = UIFont.systemFont(ofSize: 20.0)
				pickerLabel?.textAlignment = .right
				
				//				print("---------->>>>>>>>>>", tempStage, row)
				pickerLabel?.text = methodFinder.findName(requestStage: tempStage, requestRow: row)
				//		  pickerLabel?.textColor = UIColor.red
			}
		}
		
		return pickerLabel!
	}
	
	// Global Variables are not (allegedly) good.
	// Here they are.
	var currentMethodData: MethodData = MethodData(a: "", b: 0, c: " ", d: [[0]], e: false, f: false)
	
	// Copy of array from currentMethodData. This can be altered by calls, then reset from currentMethodData.
	var currentMethodArray: [[Int]] = [[0]]
	// methodName = a, bellCount = b, methodArray = c, bobValid = d, singleValid = e
	
	var currentBellSequence: String = "12345678" // Current sequence of bells, initial value ROUNDS on 4.
	var currentSelectedBell: Int = 1 // Bell the user has chosen. 1 -> 8.
	var currentBellPosition: Int = 1    // Position of currentSelectedBell, 1 = lead.
	//	var currentBellFollowsTreble: Bool = false  // is the current bell following treble?
	var currentChangeNumber: Int = 0    // how many changes into current place bell?
	var currentPlaceBell: Int = 1   // place bell that selected bell is processing.
	var currentPVStage: Int = 0	// Pickerview number of current stage
	var currentPVMethod: Int = 0
	var currentStageBellCount: Int = 4
	var lastButtonPressed: Int = 1
	var lastCorrectButton: Int = 1
	var lastButtonFollowsTreble: Bool = false
	
	var currentTrebleChecking: Bool = true // enable row 2 use, check for treble in front.
	var principalMethod: Bool = false
	var saveSender: UIButton = UIButton()   // Button the user just pressed.
	
	var buttonDownDetected: Bool = false // set true when buttonDown occurs.
	var longPressDetected: Bool = false
	var bobRequested: Bool = false
	var singleRequested: Bool = false
	var callActive: Bool = false	// call has started to take effect
	
	// Save UIButton data in array.
	//
	var saveButtonArray: [UIButton] = [UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton()]
	var saveButtonTArray: [UIButton] = [UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton(), UIButton()]
	
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	@IBOutlet weak var button4: UIButton!
	@IBOutlet weak var button5: UIButton!
	@IBOutlet weak var button6: UIButton!
	@IBOutlet weak var button7: UIButton!
	@IBOutlet weak var button8: UIButton!
	@IBOutlet weak var followTreble: UIButton!
	@IBOutlet weak var button2t: UIButton!
	@IBOutlet weak var button3t: UIButton!
	@IBOutlet weak var button4t: UIButton!
	@IBOutlet weak var button5t: UIButton!
	@IBOutlet weak var button6t: UIButton!
	@IBOutlet weak var button7t: UIButton!
	@IBOutlet weak var button8t: UIButton!
	@IBOutlet weak var bobButton: UIButton!
	@IBOutlet weak var singleButton: UIButton!
	
//	@IBOutlet weak var showCurrentPlace: UILabel!
	@IBOutlet weak var bellSequence: UILabel!
	@IBOutlet weak var leadEnd: UILabel!
	@IBOutlet weak var showHandOrBack: UILabel!
	@IBOutlet weak var showNotation: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		print("++++++++++viewDidLoad++++++++++")
		
		loadXMLData()
		
		setOrientation()
		
		self.pickerView.delegate = self
		self.pickerView.dataSource = self
		
		saveData()
		
		resetNewRequest()
		refreshDisplay()
		
		print("----------viewDidLoad----------")
		
	}
	
	//------------------------------------------------------------------------------------------------
	// Load CCCBR XML data.
	//------------------------------------------------------------------------------------------------
	
	func loadXMLData() {
		print("++++++++++loadXMLData++++++++++")
		
		//		if let path = Bundle.main.url(forResource: "XML6", withExtension: "xml") {
		if let path = Bundle.main.url(forResource: "CCCBRData", withExtension: "xml") {
			
			if let parser = XMLParser(contentsOf: path) {
				parser.delegate = self
				parser.parse()
			}
		}
		print("XML count", cccbrMethods.count)
		print("----------loadXMLData----------")
		
		
		// Use CCCBR data to load my data array.
		methodFinder.extractXMLData(cccbrData: cccbrMethods)
	}
	
	//------------------------------------------------------------------------------------------------
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		
		//	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		
		if elementName == "method" {
			xmlMethodOrSet = elementName
			xmlTitle = String()
			xmlNotation = String()
			xmlSymmetry = String()
			xmlLeadHeadCode = String()
		}
		if elementName == "methodSet" {
			xmlMethodOrSet = elementName
			xmlTitle = String()
			xmlStage = String()
			xmlClassification = String()
			xmlLengthOfLead = String()
			xmlNumberOfHunts = String()
			xmlNotation = String()
			xmlSymmetry = String()
			xmlLeadHeadCode = String()
			
		}
		if (elementName == "classification"  && attributeDict.count > 0) {
			//			print("classification", attributeDict.count, attributeDict)
			
			let dictArray = Array(attributeDict)
			//			print("dictArray", dictArray.count)
			if dictArray.count > 1 {
				//				print(">>contents>>", dictArray[0].key, dictArray[0].value)
			}
		}
		self.elementName = elementName
	}
	//------------------------------------------------------------------------------------------------
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "method" {
			xmlMethodOrSet = "methodSet"
			let cccbrMethod = CCCBRData(cccbrTitle: xmlTitle, cccbrStage: xmlStage, cccbrClassification: xmlClassification, cccbrLengthOfLead: xmlLengthOfLead, cccbrNumberOfHunts: xmlNumberOfHunts, cccbrNotation: xmlNotation, cccbrSymmetry: xmlSymmetry, cccbrLeadHeadCode: xmlLeadHeadCode)
			cccbrMethods.append(cccbrMethod)
		}
		if elementName == "methodSet" {
			xmlMethodOrSet = ""
		}
	}
	//------------------------------------------------------------------------------------------------
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		
		if (!data.isEmpty) {
			
			if xmlMethodOrSet == "method" {
				let listoftags = ["classification","stage", "lengthOfLead", "numberOfHunts", "huntbellPath", "properties"]
				
				if listoftags.contains(self.elementName) {
					print("FOUND ", self.elementName, "in", xmlMethodOrSet, "<<<<<-----<<<<<-----<<<<<-----<<<<<")
				}
			}
			
			if xmlMethodOrSet == "methodSet" {
				let listoftags = ["leadHead", "leadHeadCode", "symmetry"]
				if listoftags.contains(self.elementName) {
					print("FOUND ", self.elementName, "<<<<<-----<<<<<-----<<<<<-----<<<<<")
				}
			}
			
			switch self.elementName {
			case "title": xmlTitle += data
			case "notation": xmlNotation += data
			case "stage": xmlStage += data
			case "classification": xmlClassification += data
			case "lengthOfLead": xmlLengthOfLead += data
			case "numberOfHunts": xmlNumberOfHunts += data
			case "symmetry": xmlSymmetry += data
			case "leadHeadCode": xmlLeadHeadCode += data
			default: break
			}
		}
	}
	
	//------------------------------------------------------------------------------------------------
	// Store button data.
	//------------------------------------------------------------------------------------------------
	
	func saveData() {
		
		saveButtonArray[1] = button1
		saveButtonArray[2] = button2
		saveButtonArray[3] = button3
		saveButtonArray[4] = button4
		saveButtonArray[5] = button5
		saveButtonArray[6] = button6
		saveButtonArray[7] = button7
		saveButtonArray[8] = button8
		saveButtonTArray[2] = button2t
		saveButtonTArray[3] = button3t
		saveButtonTArray[4] = button4t
		saveButtonTArray[5] = button5t
		saveButtonTArray[6] = button6t
		saveButtonTArray[7] = button7t
		saveButtonTArray[8] = button8t
		
		bobButton.isEnabled = false
		singleButton.isEnabled = false
	}
	
	//------------------------------------------------------------------------------------------------
	// See what the user changed - stage or method.
	//------------------------------------------------------------------------------------------------
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		//        var bellCount: Int
		//		print("++++++++++pickerview: component", component, "row", row)
		
		// Stage name changed. Reload list of methods
		if component == 1 {
			currentPVStage = row
			currentPVMethod = 0
			currentStageBellCount = stageFinder.findStageBells(requestStage: row)
			//			print("pickerView: bellCount", currentStageBellCount)
			
			// Make sure selected bell is not too high for this stage.
			if currentSelectedBell > currentStageBellCount {
				currentSelectedBell = currentStageBellCount
			}
			if currentPlaceBell > currentStageBellCount {
				currentPlaceBell = currentStageBellCount
			}
			if lastButtonPressed > currentStageBellCount {
				lastButtonPressed = currentStageBellCount
				lastCorrectButton = lastButtonPressed
				lastButtonFollowsTreble = false
			}
			
			//			print("pickerView: reloadComponent(0)")
			pickerView.reloadComponent(0)
			self.pickerView.selectRow(0, inComponent: 0, animated: true)
			//        }
		} else {
			currentPVMethod = row
			// Method changed.
		}
		resetNewRequest()
		
		refreshDisplay()
		//		print("----------pickerview----------")
	}
	
	//--------------------
	// Reset variables for new method, stage or place bell.
	//--------------------
	func resetNewRequest() {
		
		print("++++++++++resetNewRequest++++++++++")
		
		bobRequested = false
		singleRequested = false
		lastButtonPressed = currentSelectedBell
		lastCorrectButton = currentSelectedBell
		if currentSelectedBell - ((currentSelectedBell / 100) * 100) == 2 {
			lastButtonFollowsTreble = true
		} else {
			lastButtonFollowsTreble = false
		}
		currentBellSequence = String("12345678".prefix(currentStageBellCount))
		
		
		currentBellPosition = currentSelectedBell
		currentPlaceBell = currentSelectedBell
		if currentPlaceBell > 100 {
			currentPlaceBell = currentPlaceBell - 100
		}
		currentChangeNumber = 0
		self.showHandOrBack.text = "Handstroke next"
		currentMethodData = methodFinder.findMethodData(requestStage: currentPVStage, requestRow: currentPVMethod)
		currentMethodArray = currentMethodData.methodArray
		
		print("----------resetNewRequest----------")
	}
	
	//--------------------
	// Refresh the display. Get method details, reset global variables, reset screen.
	//--------------------
	func refreshDisplay() {
		
		print("++++++++++refreshDisplay++++++++++")
		
		bobButton.isEnabled = currentMethodData.bobValid
		singleButton.isEnabled = currentMethodData.singleValid
		
		print(currentMethodData)
		self.showNotation.text = currentMethodData.methodStructure
		print(self.showNotation.text as Any)
		
		
		bellSequence.text = String(currentBellSequence.prefix(currentStageBellCount))
		
		if currentMethodData.methodName.contains("Stedman") {
			principalMethod = true
			print(currentMethodData.methodName)
			currentTrebleChecking = false
			followTreble.isEnabled = false
		} else {
			principalMethod = false
			followTreble.isEnabled = true
		}
		
		if currentTrebleChecking {
			followTreble.setTitleColor(UIColor.black, for: .normal)
		} else {
			followTreble.setTitleColor(UIColor.gray, for: .normal)
		}
		
		setAllYellow()
		
		print("refreshDisplay: stagebells", currentStageBellCount,
			  "currentTrebleChecking", currentTrebleChecking,
			  "lastButtonFollowsTreble", lastButtonFollowsTreble,
			  "lastButtonPressed", lastButtonPressed,
			  "lastCorrectButton", lastCorrectButton,
			  "currentPlaceBell", currentPlaceBell)
		
		var newColour: UIColor
		for i in 1...8 {
			if i > currentStageBellCount {
				saveButtonArray[i].isEnabled = false
				saveButtonArray[i].setTitleColor(UIColor.gray, for: .normal)
				saveButtonArray[i].layer.borderWidth = 0
				
				saveButtonTArray[i].isEnabled = false
				saveButtonTArray[i].setTitleColor(UIColor.gray, for: .normal)
				saveButtonTArray[i].layer.borderWidth = 0
				
			} else {
				saveButtonArray[i].isEnabled = true
				saveButtonArray[i].setTitleColor(UIColor.black, for: .normal)
				saveButtonTArray[i].isEnabled = true
				saveButtonTArray[i].setTitleColor(UIColor.black, for: .normal)
				
				if !currentTrebleChecking {
					saveButtonTArray[i].isEnabled = false
					saveButtonTArray[i].setTitleColor(UIColor.gray, for: .normal)
				}
				
				saveButtonArray[i].layer.borderWidth = 0
				saveButtonTArray[i].layer.borderWidth = 0
				
				if i == currentPlaceBell {
					saveButtonArray[i].layer.borderWidth = 2
					saveButtonArray[i].layer.borderColor = UIColor.black.cgColor
				}
			}
		}
		
		// Set colour of button pressed, and if wrong, the correct one. Also show if following treble.
		if lastButtonPressed == lastCorrectButton {
			newColour = UIColor.green
			if !currentTrebleChecking && lastButtonFollowsTreble {
				saveButtonTArray[lastButtonPressed].backgroundColor = UIColor.green
			}
		} else {
			newColour = UIColor.red
			if lastCorrectButton < 100 {
				saveButtonArray[lastCorrectButton].backgroundColor = UIColor.green
			} else {
				saveButtonTArray[lastCorrectButton].backgroundColor = UIColor.green
			}
		}
		if lastButtonPressed < 100  {
			saveButtonArray[lastButtonPressed].backgroundColor = newColour
		} else {
			saveButtonTArray[(lastButtonPressed - ((lastButtonPressed / 100) * 100))].backgroundColor = newColour
		}

			
			
			//					newColour = UIColor.green
			//				} else {
			//					newColour = UIColor.red
			//					if lastCorrectButton < 100 {
			//						saveButtonArray[lastCorrectButton].backgroundColor = UIColor.green
			//					} else {
			//						saveButtonTArray[lastCorrectButton - 100].backgroundColor = UIColor.green
			//					}
			//				}
			//				if lastButtonPressed < 100  {
			//					saveButtonArray[lastButtonPressed].backgroundColor = newColour
			//				} else {
			//					saveButtonTArray[(lastButtonPressed - ((lastButtonPressed / 100) * 100))].backgroundColor = newColour
			//				}
			//				if !currentTrebleChecking && lastButtonFollowsTreble {
			//					saveButtonTArray[lastCorrectButton].backgroundColor = UIColor.green
			//				}
			//			}   //&& !(lastButtonPressed == 2 && lastButtonFollowsTreble)
		
		if !bobRequested {
			bobButton.backgroundColor = UIColor.clear
		}
		if singleRequested {
			singleButton.backgroundColor = UIColor.clear
		}
		
		let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentPVStage, requestRow: currentPVMethod)
		
		bobButton.isEnabled = bobValid
		singleButton.isEnabled = singleValid
		
		print("----------refreshDisplay----------")
		
	}
	
	//------------------------------------------------------------------------------------------
	func setAllYellow() {
		let blist = [button1,button2,button3,button4,button5,button6,button7,button8,button2t,button3t,button4t,button5t,button6t,button7t,button8t]
		for bname in blist {
			bname!.backgroundColor = UIColor.yellow
			bname!.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			bname!.setTitleColor(UIColor.blue, for: .normal)
		}
	}
	
	//------------------------------------------------------------------------------------------------
	@IBAction func bobButton(_ sender: UIButton  ) {
		if bobButton.backgroundColor == UIColor.green {
			bobButton.backgroundColor = UIColor.clear
			bobRequested = false
		} else {
			bobButton.backgroundColor = UIColor.green
			bobRequested = true
			singleButton.backgroundColor = UIColor.clear
			singleRequested = false
		}
		print("bobButton: bobButton", bobButton.backgroundColor as Any, "singleButton", singleButton.backgroundColor as Any)
	}
	//------------------------------------------------------------------------------------------------
	@IBAction func singleButton(_ sender: UIButton) {
		//        print("SINGLE button pressed, valid = ", singleValid)
		if singleButton.backgroundColor == UIColor.green  {
			singleButton.backgroundColor = UIColor.clear
			singleRequested = false
		} else {
			singleButton.backgroundColor = UIColor.green
			singleRequested = true
			bobButton.backgroundColor = UIColor.clear
			bobRequested = false
		}
		print("singleButton: bobButton", bobButton.backgroundColor as Any, "singleButton", singleButton.backgroundColor as Any)
	}
	//------------------------------------------------------------------------------------------------
	@IBAction func trebleOption(_ sender: UIButton) {
		print("++++++++++trebleOption: started")
		longPressDetected = false
		
		if currentTrebleChecking == false {
			print("trebleOption: check treble now active")
			currentTrebleChecking = true
		} else {
			print("trebleOption: check treble now inactive")
			currentTrebleChecking = false
			if lastButtonPressed > 100 {
				lastButtonPressed = lastButtonPressed - 100
			}
		}
		
		refreshDisplay()
		print("----------trebleOption----------")
	}
	//------------------------------------------------------------------------------------------------
	@IBAction func longPressSeen(_ sender: UILongPressGestureRecognizer) {
		
		//		if (sender.state == UIGestureRecognizer.State.ended) {
		//			print("Long press Ended")
		//		}
		if (sender.state == UIGestureRecognizer.State.began) {
			//			print("Long press detected.") // buttonStarted=", buttonStarted)
			// Prevent long press on disabled button.
			if buttonDownDetected {
				saveButtonArray[currentPlaceBell].layer.borderWidth = 0
				saveSender.layer.borderWidth = 2
				saveSender.layer.borderColor = UIColor.red.cgColor
				saveSender.setTitleColor(UIColor.blue, for: .normal)
				longPressDetected = true
			}
		}
	}
	
	//------------------------------------------------------------------------------------------------
	// Action when a button is initially pressed.
	//------------------------------------------------------------------------------------------------
	@IBAction func buttonDown(_ sender: UIButton) {
		print("buttonDown: sender=", sender.tag)
		saveSender = sender
		print("button down", sender.tag)
		if sender.tag != 99 {  // Tag 99 is the "FollowTreble" button. Long press ignored.
			buttonDownDetected = true
			//  self.showCurrentPlace.textColor = UIColor.black
		}
	}
	
	//------------------------------------------------------------------------------------------------
	// Action when a button is releaased.
	//------------------------------------------------------------------------------------------------
	@IBAction func buttonPressed(_ sender: UIButton) {
		
		print("++++++++++button Pressed++++++++++")
		buttonDownDetected = false
		
		sender.setTitleColor(UIColor.black, for: .normal)
		sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			sender.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			sender.setTitleColor(UIColor.blue, for: .normal)
		}
		
		//		print("longPressDetected", longPressDetected, buttonDownDetected, currentPlaceBell)
		//------------------------------------------------------------------------------------------------
		// Handle long press.
		//------------------------------------------------------------------------------------------------
		
		if longPressDetected {
			currentSelectedBell = sender.tag
			if currentSelectedBell > 100 {
				currentSelectedBell = currentSelectedBell - 100
			}
			if currentSelectedBell == 2 {
				lastButtonFollowsTreble = true
				if currentTrebleChecking {
					currentSelectedBell = 102
				}
			}
			
			resetNewRequest()
			refreshDisplay()
			
			longPressDetected = false
			
			
			//------------------------------------------------------------------------------------------------
			// Handle normal press.
			//------------------------------------------------------------------------------------------------
		} else {
			if callActive {
				print("ViewController: reset bob/single buttons.")
				
				let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentPVStage, requestRow: currentPVMethod)
				
				bobButton.isEnabled = bobValid
				singleButton.isEnabled = singleValid
				bobRequested = false
				singleRequested = false
				bobButton.backgroundColor = UIColor.clear
				singleButton.backgroundColor = UIColor.clear
			}
			
			let (newMethodArray, newBellPosition, newFollowsTreble, newBellSequence, newPlaceBell, callStarted)
				= methodFinder.findNextPosition(
					currentMethodArray: currentMethodArray,
					currentUserBell: currentSelectedBell,
					currentBellPosition: currentBellPosition,
					currentChangeNumber: currentChangeNumber,
					currentBellSequence: currentBellSequence,
					currentPlaceBell: currentPlaceBell,
					bobRequested: bobRequested,
					singleRequested: singleRequested)
			
			callActive = callStarted
			lastButtonPressed = sender.tag
			lastCorrectButton = newBellPosition
			lastButtonFollowsTreble = newFollowsTreble
			
			if (newFollowsTreble && currentTrebleChecking) {
				lastCorrectButton = newBellPosition + 100
			}
			print("buttonpressed", sender.tag, "correct button", lastCorrectButton, "follow treble", newFollowsTreble)
			
			bellSequence.text = newBellSequence
			currentBellSequence = newBellSequence
			currentMethodArray = newMethodArray
			
			if newPlaceBell != 0 {
				print("new place bell was", currentPlaceBell, "now", newPlaceBell)
				leadEnd.text = " >>>Lead End<<<"
				leadEnd.layer.borderWidth = 1
				leadEnd.layer.borderColor = UIColor.red.cgColor
				currentPlaceBell = newPlaceBell
				currentChangeNumber = 0
				currentMethodArray = currentMethodData.methodArray
			} else {
				leadEnd.text = "               "
				leadEnd.layer.borderWidth = 0
//				leadEnd.layer.borderColor = UIColor.red.cgColor
				currentChangeNumber = currentChangeNumber + 1
			}
			showHandOrBack.layer.borderWidth = 0
			if self.showHandOrBack.text == "Backstroke next" {
				self.showHandOrBack.text = "Handstroke next"
			} else {
				self.showHandOrBack.text = "Backstroke next"
			}
			
			if callActive {
				var mp3Name: String
				print("ViewController: Say Bob or Single")
				bobButton.isEnabled = false
				singleButton.isEnabled = false
				if bobRequested == true {
					mp3Name = "bob"
				} else {
					mp3Name = "single"
				}
				let url1 = Bundle.main.url(forResource: mp3Name, withExtension: "wav")
				player = try! AVAudioPlayer(contentsOf: url1!)
				player.play()
				
			}
			
			currentBellPosition = newBellPosition
//			buttonDownDetected = false
			print("callStarted#2", callActive)
			
			refreshDisplay()
			
			print("----------Button pressed----------")
		}
	}
	
	//----------------------------------------------------------------------------
	//	func setButtonColour(senderCode: UIButton, colourWanted: UIColor) {
	//		(senderCode as UIButton).backgroundColor = colourWanted
	//		(senderCode as UIButton).setTitleColor(UIColor.black, for: .normal)
	//		(senderCode as UIButton).titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
	//
	//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
	//			(senderCode as UIButton).titleLabel?.font = UIFont.systemFont(ofSize: 15)
	//			(senderCode as UIButton).setTitleColor(UIColor.blue, for: .normal)
	//
	//		}
	//
	//
	//	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

