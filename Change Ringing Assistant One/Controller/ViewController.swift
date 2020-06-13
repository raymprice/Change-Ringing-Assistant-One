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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, XMLParserDelegate, AVAudioPlayerDelegate{
	
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
			//			print("Landscape")
			landscapeOrientation = true
			self.followTreble.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
			self.followTreble.setTitle("Follow\nTreble:", for: .normal)
		} else {
			//			print("Portrait")
			landscapeOrientation = false
			self.followTreble.setTitle("F-T:", for: .normal)
		}
	}
	
	var player: AVAudioPlayer!
	var player2: AVAudioPlayer!
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
	//	var currentMethodArray: [[Int]] = [[0]]
	// methodName = a, bellCount = b, methodArray = c, bobValid = d, singleValid = e
	
	var landscapeOrientation: Bool = false
	var currentSelectedBell: Int = 1 // Bell the user has chosen. 1 -> 8.
	var currentPVStage: Int = 0	// Pickerview number of current stage
	var currentPVMethod: Int = 0 // Pickerview number of selected method.
	var currentStageBellCount: Int = 4
	var currentTrebleChecking: Bool = true // enable row 2 use, check for treble in front.
	var principalMethod: Bool = false
	var teachingMode: Bool = false
	var timerStarted:Bool = false
	var timeSpace: Double = 0.3
//	let semaphore = DispatchSemaphore(value: 0)
	var soundInProgress: Bool = false
	
	var lastButtonPressed: Int = 1
	var lastButtonFollowsTreble: Bool = false
	var lastCorrectBellPosition: Int = 1
	var lastCorrectFollowsTreble: Bool = false
	// Copy of array from currentMethodData. This can be altered by calls, then reset from currentMethodData.
	var lastMethodArray: [[Int]] = [[0]]
	var lastBellSequence: String = "12345678" // Current sequence of bells, initial value ROUNDS on 4.
	var lastPlaceBell: Int = 0
	var lastChangeNumber: Int = 0
	var lastAnimate: Bool = false
	
	
	var nextCorrectBellPosition: Int = 0
	var nextCorrectFollowsTreble: Bool = false
	var nextMethodArray: [[Int]] = [[0]]
	var nextCallStarted: Bool = false // call will be started on next button press.
	var nextBellSequence: String = "12345678"
	var nextPlaceBell: Int = 0
	
	var saveSender: UIButton = UIButton()   // Button the user just pressed.
	var boldSender: UIButton = UIButton()
	
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
	@IBOutlet weak var hintButton: UIButton!
	
	@IBOutlet weak var titleLabel: UILabel!
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
		findNextButton()
		refreshDisplay()
		
		//		print("----------viewDidLoad----------")
	}
	
	//------------------------------------------------------------------------------------------------
	// Load CCCBR XML data.
	//------------------------------------------------------------------------------------------------
	
	func loadXMLData() {
		//		print("++++++++++loadXMLData++++++++++")
		if let path = Bundle.main.url(forResource: "CCCBRData", withExtension: "xml") {
			if let parser = XMLParser(contentsOf: path) {
				parser.delegate = self
				parser.parse()
			}
		}
		//		print("XML count", cccbrMethods.count)
		//		print("----------loadXMLData----------")
		
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
					//					print("FOUND ", self.elementName, "in", xmlMethodOrSet, "<<<<<-----<<<<<-----<<<<<-----<<<<<")
				}
			}
			
			if xmlMethodOrSet == "methodSet" {
				let listoftags = ["leadHead", "leadHeadCode", "symmetry"]
				if listoftags.contains(self.elementName) {
					//					print("FOUND ", self.elementName, "<<<<<-----<<<<<-----<<<<<-----<<<<<")
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
		
		teachingMode = false
		// Stage name changed. Reload list of methods
		if pickerView.tag == 2 {
			currentPVStage = row
			// See if method of same name available at new stage, otherwise go to top of method list.
			currentPVMethod = methodFinder.methodNameSearch(requestStage: row, requestName: currentMethodData.methodName)
			if currentPVMethod < 0 {
				currentPVMethod = 0
			}
			// Make sure selected bell is not too high for new stage.
			currentStageBellCount = stageFinder.findStageBells(requestStage: row)
			if currentSelectedBell > currentStageBellCount {
				currentSelectedBell = currentStageBellCount
			}
			// Load list of method names for newly selected stage.
			pickerView1.reloadComponent(0)
			self.pickerView1.selectRow(currentPVMethod, inComponent: 0, animated: true)
		} else {
			// Method changed.
			currentPVMethod = row
		}
		resetNewRequest()
		findNextButton()
		refreshDisplay()
		//		print("----------pickerview----------")
	}
	
	//------------------------------------------------------//
	// Reset variables for new method, stage or place bell. //
	//------------------------------------------------------//
	func resetNewRequest() {
		//		print("++++++++++resetNewRequest++++++++++")
		callActive = false
		bobRequested = false
		singleRequested = false
		lastButtonPressed = currentSelectedBell
		lastCorrectBellPosition = currentSelectedBell
		if currentSelectedBell == 2 {
			lastCorrectFollowsTreble = true
		} else {
			lastCorrectFollowsTreble = false
		}
		lastButtonFollowsTreble = lastCorrectFollowsTreble
		lastBellSequence = String("12345678".prefix(currentStageBellCount))
		lastPlaceBell = currentSelectedBell
		lastChangeNumber = 0
		self.showHandOrBack.text = "Handstroke next"
		currentMethodData = methodFinder.findMethodData(requestStage: currentPVStage, requestRow: currentPVMethod)
		lastMethodArray = currentMethodData.methodArray
		if currentMethodData.methodName.contains("Stedman") {
			principalMethod = true
			//			print(currentMethodData.methodName)
			currentTrebleChecking = false
		} else {
			principalMethod = false
			followTreble.isEnabled = true
		}
		teachingMode = false
		timerStarted = false
		
		//		print("----------resetNewRequest----------")
	}
	
	//----------------------//
	// Refresh the display. //
	//----------------------//
	func refreshDisplay() {
		
		//		print("++++++++++refreshDisplay++++++++++")
		//		print(currentMethodData)
		
		if teachingMode {
			titleLabel.text = "Show Your Place"
			hintButton.setTitle("HINT", for: .normal)
			hintButton.setTitleColor(UIColor.black, for: .normal)
		} else {
			titleLabel.text = "Know Your Place"
			hintButton.setTitle("Hint", for: .normal)
			hintButton.setTitleColor(UIColor.blue, for: .normal)
		}
		
		setOrientation()
		
		bobButton.isEnabled = currentMethodData.bobValid
		singleButton.isEnabled = currentMethodData.singleValid
		if callActive {
			bobButton.isEnabled = false
			singleButton.isEnabled = false
		}
		self.showNotation.text = currentMethodData.methodStructure
		bellSequence.text = lastBellSequence
		// + ":" + String(nextCorrectBellPosition) + " " + String(nextCorrectFollowsTreble)
		if currentTrebleChecking {
			followTreble.setTitleColor(UIColor.black, for: .normal)
		} else {
			followTreble.setTitleColor(UIColor.gray, for: .normal)
		}
		if teachingMode {
			followTreble.isEnabled = false
		} else {
			followTreble.isEnabled = true
		}
		// Set all buttons to yellow.
		let blist = [button1,button2,button3,button4,button5,button6,button7,button8,button2t,button3t,button4t,button5t,button6t,button7t,button8t]
		for bname in blist {
			bname!.backgroundColor = UIColor.yellow
			bname!.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			bname!.setTitleColor(UIColor.blue, for: .normal)
		}
		followTreble.layer.borderWidth = 0
		if lastButtonFollowsTreble {
			boldSender = saveButtonTArray[lastButtonPressed]
		} else {
			boldSender = saveButtonArray[lastButtonPressed]
		}
		
		//		// Put BOLD on pressed button for 0.5 seconds.
		//		boldSender.setTitleColor(UIColor.black, for: .normal)
		//		boldSender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
		//			self.boldSender.titleLabel?.font = UIFont.systemFont(ofSize: 15)
		//			self.boldSender.setTitleColor(UIColor.blue, for: .normal)
		//		}
		
		//		print("refreshDisplay: stagebells", currentStageBellCount, "currentTrebleChecking", currentTrebleChecking, "lastCorrectBellPosition", lastCorrectBellPosition, "lastCorrectFollowsTreble", lastCorrectFollowsTreble, "lastButtonPressed", lastButtonPressed, "lastButtonFollowsTreble", lastButtonFollowsTreble, "currentPlaceBell", lastPlaceBell)
		
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
				if teachingMode {
					saveButtonArray[i].isEnabled = false
					saveButtonTArray[i].isEnabled = false
				}
				
				if !currentTrebleChecking {
					saveButtonTArray[i].isEnabled = false
					saveButtonTArray[i].setTitleColor(UIColor.gray, for: .normal)
				}
				
				saveButtonArray[i].layer.borderWidth = 0
				saveButtonTArray[i].layer.borderWidth = 0
				if i == lastPlaceBell {
					saveButtonArray[i].layer.borderWidth = 2
					saveButtonArray[i].layer.borderColor = UIColor.black.cgColor
				}
			}
		}
		
		// Set colour of button pressed, and if wrong, the correct one. Also show if following treble.
		if lastButtonPressed == lastCorrectBellPosition {
			if !currentTrebleChecking {
				saveButtonArray[lastButtonPressed].backgroundColor = UIColor.green
				animateButton(sender: saveButtonArray[lastButtonPressed])
				if lastCorrectFollowsTreble {
					saveButtonTArray[lastButtonPressed].backgroundColor = UIColor.green
				}
			} else {
				if lastButtonFollowsTreble && lastCorrectFollowsTreble {
					saveButtonTArray[lastButtonPressed].backgroundColor = UIColor.green
					animateButton(sender: saveButtonTArray[lastButtonPressed])
				} else {
					if !lastButtonFollowsTreble && !lastCorrectFollowsTreble {
						saveButtonArray[lastButtonPressed].backgroundColor = UIColor.green
						animateButton(sender: saveButtonArray[lastButtonPressed])
					} else {
						if lastButtonFollowsTreble && !lastCorrectFollowsTreble {
							saveButtonTArray[lastButtonPressed].backgroundColor = UIColor.red
							saveButtonArray[lastButtonPressed].backgroundColor = UIColor.green
						} else {
							saveButtonArray[lastButtonPressed].backgroundColor = UIColor.red
							saveButtonTArray[lastButtonPressed].backgroundColor = UIColor.green
						}
					}
				}
			}
			
			
		} else {
			if lastButtonFollowsTreble {
				saveButtonTArray[lastButtonPressed].backgroundColor = UIColor.red
			} else {
				saveButtonArray[lastButtonPressed].backgroundColor = UIColor.red
			}
			if lastCorrectFollowsTreble {
				saveButtonTArray[lastCorrectBellPosition].backgroundColor = UIColor.green
			} else {
				saveButtonArray[lastCorrectBellPosition].backgroundColor = UIColor.green
			}
		}
		
		bobButton.backgroundColor = UIColor.clear
		singleButton.backgroundColor = UIColor.clear
		
		if bobRequested {
			bobButton.backgroundColor = UIColor.green
		}
		if singleRequested {
			singleButton.backgroundColor = UIColor.green
		}
		
		//		print("----------refreshDisplay----------")
		
		let timedTask = DispatchWorkItem {
			//			print("++++++++++self.processButton++++++++++", self.nextCorrectBellPosition, self.nextCorrectFollowsTreble, self.timerStarted, self.teachingMode)
			
			if self.teachingMode && self.timerStarted {
				self.timerStarted = false
				//				print("++++++++++self.processButton++++++++++", self.nextCorrectBellPosition, self.nextCorrectFollowsTreble, self.timerStarted)
				if self.nextCorrectFollowsTreble {
					self.saveSender = self.saveButtonTArray[self.nextCorrectBellPosition]
				} else {
					self.saveSender = self.saveButtonArray[self.nextCorrectBellPosition]
				}
				self.processButton()
			} else {
				self.timerStarted = false
			}
		}
		
		//		print("----->", self.teachingMode, timerStarted)
		
		if self.teachingMode && !timerStarted {
			timerStarted = true
			//			print("start timer")
			var timeGap = (Double(currentStageBellCount) * timeSpace) //+ timeSpace
			if currentStageBellCount == 5 || currentStageBellCount == 7 {
				timeGap = timeGap + timeSpace
			}
			if self.showHandOrBack.text == "Handstroke next" {
				timeGap = timeGap + timeSpace
			}
			//			print(self.showHandOrBack.text as Any, timeGap)
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeGap, execute: timedTask)
		}
	}
	
	func animateButton(sender: UIButton) {
		if lastAnimate {
			sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
			UIView.animate(withDuration: 1.0,
						   delay: 0,
						   usingSpringWithDamping: CGFloat(0.20),
						   initialSpringVelocity: CGFloat(6.0),
						   options: UIView.AnimationOptions.allowUserInteraction,
						   animations: {sender.transform = CGAffineTransform.identity},
						   completion: { Void in() })
		}
		lastAnimate = false
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
		findNextButton()
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
		findNextButton()
		refreshDisplay()
	}
	
	//------------------------------------------------------------------------------------------------
	// HINT request button pressed.
	//------------------------------------------------------------------------------------------------
	@IBAction func hintButton(_ sender: UIButton) {
		//		print("hintButton")
		if teachingMode {
			teachingMode = false
			refreshDisplay()
		} else {
			if nextCorrectFollowsTreble {
				saveButtonTArray[nextCorrectBellPosition].layer.borderWidth = 1
			} else {
				saveButtonArray[nextCorrectBellPosition].layer.borderWidth = 1
			}
		}
	}
	
	@IBAction func hintButtonRepeat(_ sender: UIButton) {
		//		print("hintButtonRepeat")
		if teachingMode {
			teachingMode = false
			timerStarted = false
		} else {
			teachingMode = true
			if !principalMethod {
				currentTrebleChecking = true
			} else {
				currentTrebleChecking = false
			}
		}
		refreshDisplay()
	}
	//------------------------------------------------------------------------------------------------
	// Follow-Treble request button released.
	//------------------------------------------------------------------------------------------------
	@IBAction func trebleOption(_ sender: UIButton) {
		if !principalMethod {
			if currentTrebleChecking == false {
				currentTrebleChecking = true
			} else {
				currentTrebleChecking = false
				lastButtonFollowsTreble = false
			}
		}
		refreshDisplay()
	}
	//------------------------------------------------------------------------------------------------
	// Long press detected.
	//------------------------------------------------------------------------------------------------
	@IBAction func longPressSeen(_ sender: UILongPressGestureRecognizer) {
		//		print("longPressdetected", buttonDownDetected, saveSender.tag)
		//		if (sender.state == UIGestureRecognizer.State.ended) {
		//			print("Long press Ended")
		//		}
		if (sender.state == UIGestureRecognizer.State.began) {
			// Ignore long press on disabled button.
			if buttonDownDetected {
				longPressDetected = true
				saveButtonArray[lastPlaceBell].layer.borderWidth = 0
				saveSender.layer.borderWidth = 2
				saveSender.layer.borderColor = UIColor.red.cgColor
				saveSender.setTitleColor(UIColor.blue, for: .normal)
			}
		}
	}
	
	//------------------------------------------------------------------------------------------------
	// Action when a button is initially pressed.
	//------------------------------------------------------------------------------------------------
	@IBAction func buttonDown(_ sender: UIButton) {
		//		print("buttonDown: sender=", sender.tag)
		saveSender = sender
		longPressDetected = false
		if sender.tag != 99 {
			buttonDownDetected = true
		}
	}
	
	//------------------------------------------------------------------------------------------------
	// Action when a button is releaased.
	//------------------------------------------------------------------------------------------------
	@IBAction func buttonPressed(_ sender: UIButton) {
		print("button", sender.titleLabel?.text as Any, "pressed.", soundInProgress)
		if soundInProgress {
			print("ignored - sound is in progress.")
		} else {
			processButton()
		}
	}
	
	//------------------------------------------------------------------------------------------------
	func processButton() {
		//		print("++++++++++processButton++++++++++")
		buttonDownDetected = false
		lastAnimate = true
		
		let df = DateFormatter()
		df.dateFormat = "y-MM-dd H:m:ss.SSSS"
		
		// Put BOLD on pressed button for 0.5 seconds.
		//		saveSender.setTitleColor(UIColor.red, for: .normal)
		saveSender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.saveSender.titleLabel?.font = UIFont.systemFont(ofSize: 15)
			//			self.saveSender.setTitleColor(UIColor.blue, for: .normal)
		}
		
		//------------------------------------------------------------------------------------------------
		// Handle long press.
		//------------------------------------------------------------------------------------------------
		if longPressDetected {
			currentSelectedBell = saveSender.tag
			if currentSelectedBell > 100 {
				currentSelectedBell = currentSelectedBell - 100
			}
			if currentSelectedBell == 2 {
				lastCorrectFollowsTreble = true
				//				if currentTrebleChecking {
				//					currentSelectedBell = 102
				//				}
			}
			resetNewRequest()
			findNextButton()
			refreshDisplay()
			longPressDetected = false
		}
			//------------------------------------------------------------------------------------------------
			// Handle normal press.
			//------------------------------------------------------------------------------------------------
		else {
			if callActive {
				//				print("ViewController: reset bob/single buttons.")
				bobRequested = false
				singleRequested = false
			}
			
			callActive = nextCallStarted
			lastButtonPressed = saveSender.tag
			lastButtonFollowsTreble = false
			if lastButtonPressed > 100 {
				lastButtonPressed -= 100
				lastButtonFollowsTreble = true
			}
			lastCorrectBellPosition = nextCorrectBellPosition
			lastCorrectFollowsTreble = nextCorrectFollowsTreble
			lastBellSequence = nextBellSequence
			lastMethodArray = nextMethodArray
			
			
			
			
			
			
			//			print("buttonpressed", lastButtonPressed, "correct button", lastCorrectBellPosition, "follow treble", lastCorrectFollowsTreble)
			
			if nextPlaceBell != 0 {
				leadEnd.text = " >>>Lead End<<<"
				leadEnd.layer.borderWidth = 1
				leadEnd.layer.borderColor = UIColor.red.cgColor
				lastPlaceBell = nextPlaceBell
				lastChangeNumber = 0
				lastMethodArray = currentMethodData.methodArray
			} else {
				leadEnd.text = "               "
				leadEnd.layer.borderWidth = 0
				lastChangeNumber = lastChangeNumber + 1
			}
			showHandOrBack.layer.borderWidth = 0
			if self.showHandOrBack.text == "Backstroke next" {
				self.showHandOrBack.text = "Handstroke next"
			} else {
				self.showHandOrBack.text = "Backstroke next"
			}
			//			//Announce BOB or SINGLE.
			//			if callActive {
			//
			//				var mp3Name: String
			//				//				print("ViewController: Say Bob or Single")
			//				if bobRequested == true {
			//					mp3Name = "bob"
			//				} else {
			//					mp3Name = "single"
			//				}
			//				let url1 = Bundle.main.url(forResource: mp3Name, withExtension: "wav")
			//				print("CALL!!!!")
			//				self.player = try! AVAudioPlayer(contentsOf: url1!)
			//				DispatchQueue.main.sync {
			//
			//					self.player.play()
			//				}
			//			}
			
			
			print("soundInProgress = true")
			soundInProgress = true
			var tempSeq = lastBellSequence
			if tempSeq.count == 5 {
				tempSeq = tempSeq + "6"
			}
			if tempSeq.count == 7 {
				tempSeq = tempSeq + "8"
			}
			var bellSoundName: String = ""
			var bobOrSingle: String = ""
			//			var url1: String = ""
			
			
			//Announce BOB or SINGLE.
			if callActive {
				
				print("ViewController: Say Bob or Single")
				if bobRequested == true {
					bobOrSingle = "bob"
				} else {
					bobOrSingle = "single"
				}
				let url2 = Bundle.main.url(forResource: bobOrSingle, withExtension: "wav")
				print("CALL", bobOrSingle)
				
				self.player2?.delegate = nil
				self.player2?.stop()
				
				self.player2 = try! AVAudioPlayer(contentsOf: url2!)
				self.player2.delegate = self
				self.player2.prepareToPlay()
				self.player2.play()
				bobOrSingle = ""
				
				//					self.player = try! AVAudioPlayer(contentsOf: url1!)
				//					DispatchQueue.main.sync {
				//						self.player.play()
			}
			
			
			//			for _ in 1...lastBellSequence.count {
			print(df.string(from: Date()), "Timer loop  starting...", tempSeq)

			Timer.scheduledTimer(withTimeInterval: timeSpace, repeats: true) { (timer) in
				print(df.string(from: Date()), "Timer loop.", tempSeq)
				
				let bell1 = tempSeq.prefix(1)
				tempSeq = String(tempSeq.suffix(tempSeq.count - 1))
				if self.currentStageBellCount > 6 {
					switch bell1 {
					case "1": bellSoundName = "bell8-1"
					case "2": bellSoundName = "bell8-2"
					case "3": bellSoundName = "bell8-3"
					case "4": bellSoundName = "bell8-4"
					case "5": bellSoundName = "bell8-5"
					case "6": bellSoundName = "bell8-6"
					case "7": bellSoundName = "bell8-7"
					case "8": bellSoundName = "bell8-8"
					default: break
					}
				}else {
					switch bell1 {
					case "1": bellSoundName = "bell6-1"
					case "2": bellSoundName = "bell6-2"
					case "3": bellSoundName = "bell6-3"
					case "4": bellSoundName = "bell6-4"
					case "5": bellSoundName = "bell6-5"
					case "6": bellSoundName = "bell6-6"
					default: break
					}
				}
				let url1 = Bundle.main.url(forResource: bellSoundName, withExtension: "wav")
				//					print("Bell sound", bellSoundName, bell1, tempSeq)
				self.player?.delegate = nil
				self.player?.stop()
				self.player = try! AVAudioPlayer(contentsOf: url1!)
				self.player.delegate = self
				self.player.prepareToPlay()
				print(df.string(from: Date()), "self.player.play()", tempSeq)

				self.player.play()
				
				if tempSeq == "" {

					print(df.string(from: Date()), "timer.invalidate()", tempSeq)
					timer.invalidate()
				}
			}
			
			
			
			
			lastCorrectBellPosition = nextCorrectBellPosition
			refreshDisplay()
			//			print("----------processButton----------")
			findNextButton()
		}
	}
	
	
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { // *
		//        self.delegate?.soundFinished(self)
		
		let df = DateFormatter()
		df.dateFormat = "y-MM-dd H:m:ss.SSSS"
		print(df.string(from: Date()), "audioPlayerDidFinishPlaying.")
		print("soundInProgress = false")
		soundInProgress = false
//		semaphore.signal()
	}
	
	
	
	//----------------------------------------------------------------------------------
	// Find next button to be pressed.
	//----------------------------------------------------------------------------------
	
	func findNextButton() {
		
		//		print("currentMethodArray:", lastMethodArray,,"currentUserBell:", currentSelectedBell, "currentBellPosition:", lastCorrectBellPosition, "currentChangeNumber:", lastChangeNumber, "currentBellSequence:", lastBellSequence, "currentPlaceBell:", lastPlaceBell, "bobRequested:", bobRequested, "singleRequested:", singleRequested)
		
		(nextMethodArray, nextCorrectBellPosition, nextCorrectFollowsTreble, nextBellSequence, nextPlaceBell, nextCallStarted)
			= methodFinder.findNextPosition(
				currentMethodArray: lastMethodArray,
				currentUserBell: currentSelectedBell,
				currentBellPosition: lastCorrectBellPosition,
				currentChangeNumber: lastChangeNumber,
				currentBellSequence: lastBellSequence,
				currentPlaceBell: lastPlaceBell,
				bobRequested: bobRequested,
				singleRequested: singleRequested)
		
		if principalMethod {
			nextCorrectFollowsTreble = false
		}
		//		print("findNextButton", nextMethodArray, nextCorrectBellPosition, nextCorrectFollowsTreble, nextBellSequence, nextPlaceBell, nextCallStarted)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

