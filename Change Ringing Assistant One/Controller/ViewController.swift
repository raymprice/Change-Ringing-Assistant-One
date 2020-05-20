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
		//        print("numberOfComponents: 2")
		return 2
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var returnRowsInComponent: Int
		
		if component == 1 { //Changed//
			let tempStage = pickerView.selectedRow(inComponent: 1) //Changed//
			returnRowsInComponent = stageFinder.findStageCount(requestStage: tempStage)
		} else {
			//			let currentStage = pickerView.selectedRow(inComponent: 1) //Changed//
			returnRowsInComponent = methodFinder.methodCount(requestStage: 0) //  currentStage)
		}
		//        print("numberOfRowsInComponent:", component, returnRowsInComponent)
		return returnRowsInComponent
		
	}
	
	//	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
	//		if component == 1 { //Changed//
	//			let returnStageName = stageFinder.findStageName(requestStage: row)
	//			//            print("titleForRow:", component, row, "->", returnStageName)
	//			return returnStageName
	//		} else {
	//			let currentStage = pickerView.selectedRow(inComponent: 1) //Changed//
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
			
			if component == 1 { //Changed//
				
				//		pickerLabel?.font = UIFont.systemFont(ofSize: 20.0)
				pickerLabel?.textAlignment = .center
				
				
				pickerLabel?.text = stageFinder.findStageName(requestStage: row)
				//		  pickerLabel?.textColor = UIColor.red
			} else { //Changed//
				let tempStage = pickerView.selectedRow(inComponent: 1)
				
				//		pickerLabel?.font = UIFont.systemFont(ofSize: 20.0)
				pickerLabel?.textAlignment = .center
				
				
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
	var callActive: Bool = false
	
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
	
	@IBOutlet weak var showCurrentPlace: UILabel!
	@IBOutlet weak var bellSequence: UILabel!
	@IBOutlet weak var showHandOrBack: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		print("viewDidLoad: start")
		
		loadXMLData()
		
		setOrientation()
		
		self.pickerView.delegate = self
		self.pickerView.dataSource = self
		
		saveData()
		
		refreshDisplay()
		
		print("viewDidLoad: end")
		print("----------------")
		
	}
	
	//------------------------------------------------------------------------------------------------
	// Load CCCBR XML data.
	//------------------------------------------------------------------------------------------------
	
	func loadXMLData() {
		
		//		if let path = Bundle.main.url(forResource: "XML6", withExtension: "xml") {
		if let path = Bundle.main.url(forResource: "CCCBRData", withExtension: "xml") {
			
			if let parser = XMLParser(contentsOf: path) {
				parser.delegate = self
				parser.parse()
			}
		}
		print("XML count", cccbrMethods.count)
		
		// Use CCCBR data to load my data array.
		methodFinder.loadXMLData(cccbrData: cccbrMethods)
		
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
		print("----------")
		print("pickerview: component", component, "row", row)
		
		// Stage name changed. Reload list of methods
		if component == 1 { //Changed//
			currentPVStage = row
			currentStageBellCount = stageFinder.findStageBells(requestStage: row)
			print("pickerView: bellCount", currentStageBellCount)
			
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
			
			//			currentBellSequence = String("12345678".prefix(stageBellCount))
			//			//            bellSequence.text = currentBellSequence
			//
			//			// Disable buttons above new stage.
			//			button5.isEnabled = true
			//			button6.isEnabled = true
			//			button7.isEnabled = true
			//			button8.isEnabled = true
			//			if currentTrebleChecking == true {
			//				button5t.isEnabled = true
			//				button6t.isEnabled = true
			//				button7t.isEnabled = true
			//				button8t.isEnabled = true
			//			}
			//			if stageBellCount < 8 {
			//				button8.isEnabled = false
			//				button8t.isEnabled = false
			//			}
			//			if stageBellCount < 7 {
			//				button7.isEnabled = false
			//				button7t.isEnabled = false
			//			}
			//			if stageBellCount < 6 {
			//				button6.isEnabled = false
			//				button6t.isEnabled = false
			//			}
			//			if stageBellCount < 5 {
			//				button5.isEnabled = false
			//				button5t.isEnabled = false
			//			}
			
			print("pickerView: reloadComponent(0)") //Changed//
			pickerView.reloadComponent(0) //Changed//
			self.pickerView.selectRow(0, inComponent: 0, animated: true) //Changed//
			//        }
		} else {
			currentPVMethod = row
						//            // Method changed.
		}
		resetNewRequest()

		refreshDisplay()
		
		
	}
	
	
	//--------------------
	// Reset variables for new method, stage or place bell.
	//--------------------
	func resetNewRequest() {
		
		print("resetNewRequest")
		
		bobRequested = false
		singleRequested = false
		lastButtonPressed = currentSelectedBell
		lastCorrectButton = currentSelectedBell
		currentBellSequence = String("12345678".prefix(currentStageBellCount))
		
		
		currentBellPosition = currentSelectedBell
		currentPlaceBell = currentSelectedBell
		if currentPlaceBell > 100 {
			currentPlaceBell = currentPlaceBell - 100
		}
		//				currentBellSequence = String("12345678".prefix(currentMethodData.bellCount))
		currentChangeNumber = 0
		self.showHandOrBack.text = "Handstroke next"
		currentMethodArray = currentMethodData.methodArray
		
//		let currentStage = pickerView.selectedRow(inComponent: 1) //Changed//
//		let currentMethod = pickerView.selectedRow(inComponent: 0) //Changed//
		
		currentMethodData = methodFinder.findMethodData(requestStage: currentPVStage, requestRow: currentPVMethod)


		
		
	}
	
	
	//--------------------
	// Refresh the display. Get method details, reset global variables, reset screen.
	//--------------------
	func refreshDisplay() {
		
		print("refreshDisplay")
		
//		currentBellPosition = currentSelectedBell
		
		
		bobButton.isEnabled = currentMethodData.bobValid
		singleButton.isEnabled = currentMethodData.singleValid
		
		//        self.showCurrentPlace.textColor = UIColor.black
		//        self.showCurrentPlace.text = "Place Bell: " + String(currentSelectedBell)
		print("-------------------+++++++++++++++++++++++++++++")
		print(currentMethodData)
		self.showCurrentPlace.text = currentMethodData.methodStructure
		print(self.showCurrentPlace.text as Any)
				
		
//		currentBellSequence = String("12345678".prefix(currentStageBellCount))
//		bellSequence.text = currentBellSequence
		bellSequence.text = String(currentBellSequence.prefix(currentStageBellCount))

		
		// Disable buttons above new stage.
		//		button5.isEnabled = true
		//		button6.isEnabled = true
		//		button7.isEnabled = true
		//		button8.isEnabled = true
		//		if currentTrebleChecking == true {
		//			button5t.isEnabled = true
		//			button6t.isEnabled = true
		//			button7t.isEnabled = true
		//			button8t.isEnabled = true
		//		}
		
		
		if currentMethodData.methodName.contains("Stedman") {
			principalMethod = true
			print(currentMethodData.methodName)
			currentTrebleChecking = false
			followTreble.isEnabled = false
		} else {
			principalMethod = false
//			currentTrebleChecking = true
			followTreble.isEnabled = true
		}
		
		
		if currentTrebleChecking {
			followTreble.setTitleColor(UIColor.black, for: .normal)
		} else {
			followTreble.setTitleColor(UIColor.gray, for: .normal)
		}
		
		setAllYellow()
		
		print("refreshDisplay: stagebells", currentStageBellCount, "currentTrebleChecking", currentTrebleChecking, "lastButtonFollowsTreble", lastButtonFollowsTreble, "lastButtonPressed", lastButtonPressed, "lastCorrectButton", lastCorrectButton)
		
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
//				if i == currentPlaceBell - 100 {
//					saveButtonTArray[currentPlaceBell].layer.borderWidth = 2
//					saveButtonTArray[currentPlaceBell].layer.borderColor = UIColor.black.cgColor
//				}
				
				if lastButtonPressed == lastCorrectButton {
					newColour = UIColor.green
				} else {
					newColour = UIColor.red
					if lastCorrectButton < 100 {
						saveButtonArray[lastCorrectButton].backgroundColor = UIColor.green
					} else {
						saveButtonTArray[lastCorrectButton - 100].backgroundColor = UIColor.green
					}
				}
				if lastButtonPressed < 100  && !(lastButtonPressed == 2 && lastButtonFollowsTreble){
					saveButtonArray[lastButtonPressed].backgroundColor = newColour
				} else {
					saveButtonTArray[(lastButtonPressed - ((lastButtonPressed / 100) * 100))].backgroundColor = newColour
				}
				if !currentTrebleChecking && lastButtonFollowsTreble {
					saveButtonTArray[lastCorrectButton].backgroundColor = UIColor.green
				}
				
				
				
				
				
				
			}
			//				if i > 1 {
			//
			//					if saveButtonTArray[i].backgroundColor == UIColor.green {
			//						saveButtonArray[i].backgroundColor = UIColor.yellow
			//					}
			//
			//					if currentTrebleChecking == true {
			//						saveButtonTArray[i].isEnabled = true
			//						saveButtonTArray[i].setTitleColor(UIColor.black, for: .normal)
			//					} else {
			//						saveButtonTArray[i].isEnabled = false
			//						saveButtonTArray[i].setTitleColor(UIColor.gray, for: .normal)
			//					}
			//				}
			//
			//			}
		}
		
		//
		//
		//		if ((lastButtonFollowsTreble == false && sender.tag == lastCorrectButton)
		//			|| (lastButtonFollowsTreble && sender.tag - 100 == lastCorrectButton)
		//			|| (currentTrebleChecking == false && sender.tag == lastCorrectButton))  {
		//			self.setButtonColour(senderCode: sender, colourWanted: UIColor.green)
		//			if lastButtonFollowsTreble && principalMethod == false {
		//				setButtonColour(senderCode: saveButtonTArray[lastCorrectButton], colourWanted: UIColor.green)
		//			}
		//		}
		//		else {
		//			self.setButtonColour(senderCode: sender, colourWanted: UIColor.red)
		//
		//			// Set correct button to green.
		//			if lastButtonFollowsTreble && principalMethod != true {
		//				setButtonColour(senderCode: saveButtonTArray[lastCorrectButton], colourWanted: UIColor.green)
		//			} else {
		//				setButtonColour(senderCode: saveButtonArray[lastCorrectButton], colourWanted: UIColor.green)
		//			}
		//		}
		//
		//
		
		
		
		
		
		
		
		
//		trebleOption(followTreble)
		
		
		
		//		if currentTrebleChecking == true {
		//			followTreble.setTitleColor(UIColor.black, for: .normal)
		//			button2t.isEnabled = true
		//			button3t.isEnabled = true
		//			button4t.isEnabled = true
		//			button5t.isEnabled = true
		//			button6t.isEnabled = true
		//			button7t.isEnabled = true
		//			button8t.isEnabled = true
		
		//			if currentMethodData.bellCount < 8 {
		//				button8.isEnabled = false
		//				button8t.isEnabled = false
		//			}
		//			if currentMethodData.bellCount < 7 {
		//				button7.isEnabled = false
		//				button7t.isEnabled = false
		//			}
		//			if currentMethodData.bellCount < 6 {
		//				button6.isEnabled = false
		//				button6t.isEnabled = false
		//			}
		//			if currentMethodData.bellCount < 5 {
		//				button5.isEnabled = false
		//				button5t.isEnabled = false
		//			}
		
		//			for i in 2...8 {
		//				if saveButtonTArray[i].backgroundColor == UIColor.green {
		//					saveButtonArray[i].backgroundColor = UIColor.yellow
		//				}
		
		
		//	} else {
		//	print("trebleOption: check treble now inactive")
		//	currentTrebleChecking = false
		//	followTreble.setTitleColor(UIColor.gray, for: .normal)
		//	button2t.isEnabled = false
		//	button3t.isEnabled = false
		//	button4t.isEnabled = false
		//	button5t.isEnabled = false
		//	button6t.isEnabled = false
		//	button7t.isEnabled = false
		//	button8t.isEnabled = false
		
		
//		if currentSelectedBell < 100 {
//			saveButtonArray[currentSelectedBell].backgroundColor = UIColor.green
//		} else {
//			saveButtonTArray[currentSelectedBell - 100].backgroundColor = UIColor.green
//
//		}
//		if currentSelectedBell == 2 {
//			if currentTrebleChecking {
//				button2t.backgroundColor = UIColor.green
//				button2.backgroundColor = UIColor.yellow
//			} else {
//				button2t.backgroundColor = UIColor.green
//			}
//		}
		
		//        self.showCurrentPlace.textColor = UIColor.black
		if !bobRequested {
			bobButton.backgroundColor = UIColor.clear
		}
		if singleRequested {
			singleButton.backgroundColor = UIColor.clear
		}
		
		let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentPVStage, requestRow: currentPVMethod)
		
		bobButton.isEnabled = bobValid
		singleButton.isEnabled = singleValid
		
	}
	
	//------------------------------------------------------------------------------------------
	func setAllYellow() {
		let blist = [button1,button2,button3,button4,button5,button6,button7,button8,button2t,button3t,button4t,button5t,button6t,button7t,button8t]
		for bname in blist {
			bname!.backgroundColor = UIColor.yellow
			
			bname!.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			bname!.setTitleColor(UIColor.blue, for: .normal)
			
		}
		//        button1.backgroundColor = UIColor.yellow
		//        button2.backgroundColor = UIColor.yellow
		//        button3.backgroundColor = UIColor.yellow
		//        button4.backgroundColor = UIColor.yellow
		//        button5.backgroundColor = UIColor.yellow
		//        button6.backgroundColor = UIColor.yellow
		//        button7.backgroundColor = UIColor.yellow
		//        button8.backgroundColor = UIColor.yellow
		//        button2t.backgroundColor = UIColor.yellow
		//        button3t.backgroundColor = UIColor.yellow
		//        button4t.backgroundColor = UIColor.yellow
		//        button5t.backgroundColor = UIColor.yellow
		//        button6t.backgroundColor = UIColor.yellow
		//        button7t.backgroundColor = UIColor.yellow
		//        button8t.backgroundColor = UIColor.yellow
		//------------------------------------------------------------------------------------------------
		// Grey and disable bells above current stage
		//------------------------------------------------------------------------------------------------
		
		//		if currentStageBellCount < 8 {
		//			for i in currentStageBellCount + 1...8 {
		//				saveButtonArray[i].isEnabled = false
		//				saveButtonTArray[i].isEnabled = false
		//				saveButtonArray[i].setTitleColor(UIColor.gray, for: .normal)
		//				saveButtonTArray[i].setTitleColor(UIColor.gray, for: .normal)
		//			}
		//
		//
		//
		//
		//		}
		
		
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
		//        }
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
		print("trebleOption: started")
		longPressDetected = false
		
		if currentTrebleChecking == false {
			print("trebleOption: check treble now active")
			currentTrebleChecking = true
			//		followTreble.setTitleColor(UIColor.black, for: .normal)
			//		button2t.isEnabled = true
			//		button3t.isEnabled = true
			//		button4t.isEnabled = true
			//		button5t.isEnabled = true
			//		button6t.isEnabled = true
			//		button7t.isEnabled = true
			//		button8t.isEnabled = true
			//
			//		if currentMethodData.bellCount < 8 {
			//			button8.isEnabled = false
			//			button8t.isEnabled = false
			//		}
			//		if currentMethodData.bellCount < 7 {
			//			button7.isEnabled = false
			//			button7t.isEnabled = false
			//		}
			//		if currentMethodData.bellCount < 6 {
			//			button6.isEnabled = false
			//			button6t.isEnabled = false
			//		}
			//		if currentMethodData.bellCount < 5 {
			//			button5.isEnabled = false
			//			button5t.isEnabled = false
			//		}
			//
			//		for i in 2...8 {
			//			if saveButtonTArray[i].backgroundColor == UIColor.green {
			//				saveButtonArray[i].backgroundColor = UIColor.yellow
			//			}
			//		}
			
		} else {
			print("trebleOption: check treble now inactive")
			currentTrebleChecking = false
			//		followTreble.setTitleColor(UIColor.gray, for: .normal)
			//		button2t.isEnabled = false
			//		button3t.isEnabled = false
			//		button4t.isEnabled = false
			//		button5t.isEnabled = false
			//		button6t.isEnabled = false
			//		button7t.isEnabled = false
			//		button8t.isEnabled = false
			
//			for i in 2...8 {
//				if saveButtonTArray[i].backgroundColor != UIColor.yellow
//				{
//					saveButtonArray[i].backgroundColor = saveButtonTArray[i].backgroundColor
//					if saveButtonTArray[i].backgroundColor != UIColor.green {
//						saveButtonTArray[i].backgroundColor = UIColor.yellow
//					}
//				}
//			}
		}
		
		refreshDisplay()
	}
	//------------------------------------------------------------------------------------------------
	@IBAction func longPressSeen(_ sender: UILongPressGestureRecognizer) {
		
		if (sender.state == UIGestureRecognizer.State.ended) {
			//            longPressDetected = true
			
			print("Long press Ended")
		} else if (sender.state == UIGestureRecognizer.State.began) {
			print("Long press detected.") // buttonStarted=", buttonStarted)
			
			// Prevent long press on disabled button.
			//
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
	@IBAction func buttonDown(_ sender: UIButton) {
		
		print("buttonDown: sender=", sender.tag)
		saveSender = sender
		print("button down", sender.tag)
		if sender.tag != 99 {  // Tag 99 is the "FollowTreble" button. Long press ignored.
			buttonDownDetected = true
		//        self.showCurrentPlace.textColor = UIColor.black
//		setAllYellow()
		}
	}
	
	//------------------------------------------------------------------------------------------------
	@IBAction func buttonPressed(_ sender: UIButton) {
		
		//        var callStarted: Bool = false
		//        var callEnded: Bool = false
		//        var followsTreble: Bool = false
		//	var correctBellPosition: Int
		
		print("---------button Pressed-----------")
		print("callStarted#3", callActive)
		
		
//		let currentStage = pickerView.selectedRow(inComponent: 1) //Changed//
//		let currentMethod = pickerView.selectedRow(inComponent: 0) //Changed//
		
		
		sender.setTitleColor(UIColor.black, for: .normal)
		sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			sender.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			sender.setTitleColor(UIColor.blue, for: .normal)
			
		}
		
		
		
		print("longPressDetected", longPressDetected, buttonDownDetected, currentPlaceBell)
		
		if longPressDetected {
			if buttonDownDetected {
				
				//                saveButtonArray[currentPlaceBell].layer.borderWidth = 0
				
				currentSelectedBell = sender.tag
				if currentSelectedBell > 100 {
					currentSelectedBell = currentSelectedBell - 100
				}
				if currentSelectedBell == 2 {
//					currentSelectedBell = 102
					lastButtonFollowsTreble = true
				}
//				lastButtonPressed = currentSelectedBell
//				lastCorrectButton = currentSelectedBell
//				currentBellSequence = "12345678"
//
//
//				currentBellPosition = currentSelectedBell
//				currentPlaceBell = currentSelectedBell
////				currentBellSequence = String("12345678".prefix(currentMethodData.bellCount))
//				currentChangeNumber = 0
				
//				saveButtonTArray[currentPlaceBell].layer.borderWidth = 0
//				saveButtonArray[currentPlaceBell].layer.borderWidth = 2
//				saveButtonArray[currentPlaceBell].layer.borderColor = UIColor.black.cgColor
				
				//                if currentSelectedBell > 100 {
				//                    currentSelectedBell = selectedBell - 100
				//                }
				//                if selectedBell > stageBells {
				//                    print("Invalid long press, sender", sender.tag, "max", stageBells)
				//                    selectedBell = stageBells
				//                }
				//                print("longPress, bellChosen", selectedBell, "methodNumber", currentMethod)
				//                loadArray(bellChosen: currentSelectedBell)
				
				resetNewRequest()
				refreshDisplay()
			}
			longPressDetected = false
			
			
			// Check if correct button was pressed.
		} else {
			print("callStarted#1", callActive)
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
			
			let (newMethodArray, newBellPosition, newFollowsTreble, newBellSequence, newPlaceBell, callStarted) = methodFinder.findNextPosition(currentMethodArray: currentMethodArray, currentUserBell: currentSelectedBell, currentBellPosition: currentBellPosition, currentChangeNumber: currentChangeNumber, currentBellSequence: currentBellSequence, currentPlaceBell: currentPlaceBell, bobRequested: bobRequested, singleRequested: singleRequested)
			
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
			
//			if ((lastButtonFollowsTreble == false && sender.tag == lastCorrectButton)
//				|| (lastButtonFollowsTreble && sender.tag - 100 == lastCorrectButton)
//				|| (currentTrebleChecking == false && sender.tag == lastCorrectButton))  {
//				self.setButtonColour(senderCode: sender, colourWanted: UIColor.green)
//				if lastButtonFollowsTreble && principalMethod == false {
//					setButtonColour(senderCode: saveButtonTArray[lastCorrectButton], colourWanted: UIColor.green)
//				}
//			}
//			else {
//				self.setButtonColour(senderCode: sender, colourWanted: UIColor.red)
//
//				// Set correct button to green.
//				if lastButtonFollowsTreble && principalMethod != true {
//					setButtonColour(senderCode: saveButtonTArray[lastCorrectButton], colourWanted: UIColor.green)
//				} else {
//					setButtonColour(senderCode: saveButtonArray[lastCorrectButton], colourWanted: UIColor.green)
//				}
//			}
			
			if newPlaceBell != 0 {
				
				print("new place bell was", currentPlaceBell, "now", newPlaceBell)
				showHandOrBack.text = " >>>Lead End<<<"
				showHandOrBack.layer.borderWidth = 1
				showHandOrBack.layer.borderColor = UIColor.red.cgColor
//				saveButtonArray[currentPlaceBell].layer.borderWidth = 0
				//                saveSender.layer.borderColor = UIColor.black.cgColor
//				saveButtonArray[newPlaceBell].layer.borderWidth = 2
//				saveButtonArray[newPlaceBell].layer.borderColor = UIColor.black.cgColor
				
				currentPlaceBell = newPlaceBell
				//                self.showCurrentPlace.text = "Place Bell: " + String(currentPlaceBell)
				//                self.showCurrentPlace.textColor = UIColor.red
				currentChangeNumber = 0
				currentMethodArray = currentMethodData.methodArray
			} else {
				currentChangeNumber = currentChangeNumber + 1
				showHandOrBack.layer.borderWidth = 0
				if self.showHandOrBack.text == "Backstroke next" {
					self.showHandOrBack.text = "Handstroke next"
				} else {
					self.showHandOrBack.text = "Backstroke next"
				}
			}
			
			//            var bobRequested = false
			//            if bobButton.backgroundColor == UIColor.green {
			//                bobRequested = true
			//            }
			//
			//            var singleRequested = false
			//            if singleButton.backgroundColor == UIColor.green {
			//                singleRequested = true
			//            }
			
			//            (currentBellArray, currentBellArrayIndex, callStarted, callEnded) = methodFinder.findNextPlace(requestStage: currentStage, requestRow: currentMethod, requestArray: currentBellArray, requestArrayIndex: currentBellArrayIndex, bobRequested: bobRequested, singleRequested: singleRequested)
			
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
			//            if callEnded == true {
			//                print("ViewController: Call Ended, enable bob/single buttons.")
			//
			//                let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentStage, requestRow: currentMethod)
			//
			//                bobButton.isEnabled = bobValid
			//                singleButton.isEnabled = singleValid
			//                bobRequested = false
			//                singleRequested = false
			//                bobButton.backgroundColor = UIColor.clear
			//                singleButton.backgroundColor = UIColor.clear
			//            }
			//
			//            if self.showHandOrBack.text == "Handstroke next" {
			//                self.showHandOrBack.text = "Backstroke next"
			//            } else {
			//                self.showHandOrBack.text = "Handstroke next"
			//            }
			
			
			
			currentBellPosition = newBellPosition
			buttonDownDetected = false
			print("callStarted#2", callActive)
			
			refreshDisplay()
			
			print("End of Button pressed")
		}
	}
	
//	//----------------------------------------------------------------------------
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

