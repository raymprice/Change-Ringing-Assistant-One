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
	
	@IBOutlet weak var pickerView1: UIPickerView!
	@IBOutlet weak var pickerView2: UIPickerView!
	
	// Functions to handle pickerviews.
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		var returnRowsInComponent: Int
		if pickerView.tag == 2 {
			returnRowsInComponent = stageFinder.findStageCount(requestStage: currentPVStage)
		} else {
			returnRowsInComponent = methodFinder.methodCount(requestStage: currentPVStage)
		}
		return returnRowsInComponent
	}
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		var pickerLabel: UILabel? = (view as? UILabel)
		if pickerLabel == nil {
			pickerLabel = UILabel()
			
			if pickerView.tag == 2 {
				pickerLabel?.textAlignment = .left
				pickerLabel?.text = stageFinder.findStageName(requestStage: row)
			} else {
				pickerLabel?.textAlignment = .right
				pickerLabel?.text = methodFinder.findName(requestStage: currentPVStage, requestRow: row)
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
	
	@IBOutlet weak var bellSequence: UILabel!
	@IBOutlet weak var leadEnd: UILabel!
	@IBOutlet weak var showHandOrBack: UILabel!
	@IBOutlet weak var showNotation: UILabel!
	
	
	//------------------------------------------------------------------------------------------------
	// viewDidLoad - initialise.
	//------------------------------------------------------------------------------------------------
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		//		print("++++++++++viewDidLoad++++++++++")
		
		loadXMLData()
		
		setOrientation()
		
		self.pickerView1.delegate = self
		self.pickerView1.dataSource = self
		
		saveData()
		
		resetNewRequest()
		refreshDisplay()
		
		//		print("----------viewDidLoad----------")
	}
	
	//------------------------------------------------------------------------------------------------
	// Load CCCBR XML data.
	//------------------------------------------------------------------------------------------------
	
	func loadXMLData() {
		print("++++++++++loadXMLData++++++++++")
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
			let dictArray = Array(attributeDict)
			if dictArray.count > 1 {
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
	}
	
	//------------------------------------------------------------------------------------------------
	// See what the user changed - stage or method.
	//------------------------------------------------------------------------------------------------
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		//		print("++++++++++pickerview: component", component, "row", row)
		
		// Stage name changed. Reload list of methods
		if pickerView.tag == 2 {
			currentPVStage = row
			currentPVMethod = methodFinder.methodNameSearch(requestStage: row, requestName: currentMethodData.methodName)
			if currentPVMethod < 0 {
				currentPVMethod = 0
			}
			currentStageBellCount = stageFinder.findStageBells(requestStage: row)
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
			// Load list of method names for newly selected stage.
			pickerView1.reloadComponent(0)
			self.pickerView1.selectRow(currentPVMethod, inComponent: 0, animated: true)
		} else {
			// Method changed.
			currentPVMethod = row
		}
		resetNewRequest()
		refreshDisplay()
		//		print("----------pickerview----------")
	}
	
	//--------------------
	// Reset variables for new method, stage or place bell.
	//--------------------
	func resetNewRequest() {
		//		print("++++++++++resetNewRequest++++++++++")
		bobRequested = false
		singleRequested = false
		lastButtonPressed = currentSelectedBell
		lastCorrectButton = currentSelectedBell
		if currentSelectedBell - ((currentSelectedBell / 100) * 100) == 2 {
			currentSelectedBell = 2
			lastButtonFollowsTreble = true
		} else {
			lastButtonFollowsTreble = false
		}
		currentBellSequence = String("12345678".prefix(currentStageBellCount))
		currentBellPosition = currentSelectedBell
		currentPlaceBell = currentSelectedBell - ((currentSelectedBell / 100) * 100)
		currentChangeNumber = 0
		self.showHandOrBack.text = "Handstroke next"
		currentMethodData = methodFinder.findMethodData(requestStage: currentPVStage, requestRow: currentPVMethod)
		currentMethodArray = currentMethodData.methodArray
		if currentMethodData.methodName.contains("Stedman") {
			principalMethod = true
			print(currentMethodData.methodName)
			currentTrebleChecking = false
			followTreble.isEnabled = false
		} else {
			principalMethod = false
			followTreble.isEnabled = true
		}
		//		print("----------resetNewRequest----------")
	}
	
	//--------------------
	// Refresh the display.
	//--------------------
	func refreshDisplay() {
		
		print("++++++++++refreshDisplay++++++++++")
		print(currentMethodData)
		bobButton.isEnabled = currentMethodData.bobValid
		singleButton.isEnabled = currentMethodData.singleValid
		if callActive {
			bobButton.isEnabled = false
			singleButton.isEnabled = false
		}
		self.showNotation.text = currentMethodData.methodStructure
		bellSequence.text = currentBellSequence
		if currentTrebleChecking {
			followTreble.setTitleColor(UIColor.black, for: .normal)
		} else {
			followTreble.setTitleColor(UIColor.gray, for: .normal)
		}
		// Set all buttons to yellow.
		let blist = [button1,button2,button3,button4,button5,button6,button7,button8,button2t,button3t,button4t,button5t,button6t,button7t,button8t]
		for bname in blist {
			bname!.backgroundColor = UIColor.yellow
			bname!.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			bname!.setTitleColor(UIColor.blue, for: .normal)
		}
		
				print("refreshDisplay: stagebells", currentStageBellCount, "currentTrebleChecking", currentTrebleChecking, "lastButtonFollowsTreble", lastButtonFollowsTreble, "lastButtonPressed", lastButtonPressed, "lastCorrectButton", lastCorrectButton, "currentPlaceBell", currentPlaceBell)
		
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
				saveButtonTArray[lastCorrectButton - 100].backgroundColor = UIColor.green
			}
		}
		if lastButtonPressed < 100  {
			saveButtonArray[lastButtonPressed].backgroundColor = newColour
		} else {
			saveButtonTArray[(lastButtonPressed - ((lastButtonPressed / 100) * 100))].backgroundColor = newColour
		}
		bobButton.backgroundColor = UIColor.clear
		singleButton.backgroundColor = UIColor.clear

		if bobRequested {
			bobButton.backgroundColor = UIColor.green
		}
		if singleRequested {
			singleButton.backgroundColor = UIColor.green
		}
		
		print("----------refreshDisplay----------")
		
	}
	
	//------------------------------------------------------------------------------------------------
	// BOB request button pressed.
	//------------------------------------------------------------------------------------------------
	@IBAction func bobButton(_ sender: UIButton  ) {
		if bobRequested {
			bobRequested = false
		} else {
			bobRequested = true
			singleRequested = false
		}
		refreshDisplay()
	}
	//------------------------------------------------------------------------------------------------
	// SINGLE request button pressed.
	//------------------------------------------------------------------------------------------------
	@IBAction func singleButton(_ sender: UIButton) {
		if singleRequested {
			singleRequested = false
		} else {
			singleRequested = true
			bobRequested = false
		}
		refreshDisplay()
	}
	//------------------------------------------------------------------------------------------------
	// Follow-Treble request button pressed.
	//------------------------------------------------------------------------------------------------
	@IBAction func trebleOption(_ sender: UIButton) {
		longPressDetected = false
		if currentTrebleChecking == false {
			currentTrebleChecking = true
		} else {
			currentTrebleChecking = false
			lastButtonPressed = lastButtonPressed - ((lastButtonPressed / 100) * 100)
		}
		refreshDisplay()
	}
	//------------------------------------------------------------------------------------------------
	// Long press detected.
	//------------------------------------------------------------------------------------------------
	@IBAction func longPressSeen(_ sender: UILongPressGestureRecognizer) {
		
		//		if (sender.state == UIGestureRecognizer.State.ended) {
		//			print("Long press Ended")
		//		}
		if (sender.state == UIGestureRecognizer.State.began) {
			// Ignore long press on disabled button.
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
//		print("buttonDown: sender=", sender.tag)
		saveSender = sender
		if sender.tag != 99 {  // Tag 99 is the "FollowTreble" button. Long press ignored.
			buttonDownDetected = true
		}
	}
	
	//------------------------------------------------------------------------------------------------
	// Action when a button is releaased.
	//------------------------------------------------------------------------------------------------
	@IBAction func buttonPressed(_ sender: UIButton) {
		
		//		print("++++++++++button Pressed++++++++++")
		buttonDownDetected = false
		// Put BOLD on pressed button for 0.5 seconds.
		sender.setTitleColor(UIColor.black, for: .normal)
		sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			sender.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			sender.setTitleColor(UIColor.blue, for: .normal)
		}
		
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
		}
		//------------------------------------------------------------------------------------------------
		// Handle normal press.
		//------------------------------------------------------------------------------------------------
		else {
			if callActive {
				print("ViewController: reset bob/single buttons.")
				
				//				let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentPVStage, requestRow: currentPVMethod)
				//
				//				bobButton.isEnabled = bobValid
				//				singleButton.isEnabled = singleValid
				bobRequested = false
				singleRequested = false
				//				bobButton.backgroundColor = UIColor.clear
				//				singleButton.backgroundColor = UIColor.clear
			}
			
			// Find correct button.
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
			
			currentBellSequence = newBellSequence
			currentMethodArray = newMethodArray
			
			if newPlaceBell != 0 {
				leadEnd.text = " >>>Lead End<<<"
				leadEnd.layer.borderWidth = 1
				leadEnd.layer.borderColor = UIColor.red.cgColor
				currentPlaceBell = newPlaceBell
				currentChangeNumber = 0
				currentMethodArray = currentMethodData.methodArray
			} else {
				leadEnd.text = "               "
				leadEnd.layer.borderWidth = 0
				currentChangeNumber = currentChangeNumber + 1
			}
			showHandOrBack.layer.borderWidth = 0
			if self.showHandOrBack.text == "Backstroke next" {
				self.showHandOrBack.text = "Handstroke next"
			} else {
				self.showHandOrBack.text = "Backstroke next"
			}
			//Announce BOB or SINGLE.
			if callActive {
				var mp3Name: String
				print("ViewController: Say Bob or Single")
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
			refreshDisplay()
			//			print("----------Button pressed----------")
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

