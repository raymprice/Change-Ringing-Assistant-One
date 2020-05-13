//
//  ViewController.swift
//  Change Ringing Assistant One
//
//  Created by Ray Price on 23/11/2017.
//  Copyright © 2017 Ray Price. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    
    
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        print("numberOfComponents: 2")
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var returnRowsInComponent: Int
        
        if component == 0 {            
            let currentStage = pickerView.selectedRow(inComponent: 0)
            returnRowsInComponent = stageFinder.findStageCount(requestStage: currentStage)
        } else {
            let currentStage = pickerView.selectedRow(inComponent: 0)
            returnRowsInComponent = methodFinder.methodCount(requestStage: currentStage)
        }
//        print("numberOfRowsInComponent:", component, returnRowsInComponent)
        return returnRowsInComponent
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let returnStageName = stageFinder.findStageName(requestStage: row)
//            print("titleForRow:", component, row, "->", returnStageName)
            return returnStageName
        } else {
            let currentStage = pickerView.selectedRow(inComponent: 0)
            
            let returnMethodName = methodFinder.findName(requestStage: currentStage, requestRow: row)
//            print("titleForRow:", component, row, "->", returnMethodName)
            return returnMethodName
        }
        
    }
    
    // Global Variables are not (allegedly) good.
    // Here they are.
    var currentMethodData: MethodData = MethodData(a: "", b: 0, c: " ", d: [[0]], e: false, f: false)
    
    // Copy of array from currentMethodData. This can be altered by calls, then reset from currentMethodData.
    var currentMethodArray: [[Int]] = [[0]]
    
    /*
     methodName = a
     bellCount = b
     methodArray = c
     bobValid = d
     singleValid = e
     */
    
    var currentBellSequence: String = "1234" // Current sequence of bells, initial value ROUNDS.
    
    var currentSelectedBell: Int = 1 // Bell the user has chosen. 1 -> 8.
    var currentBellPosition: Int = 1    // Position of currentSelectedBell, 1 = lead.
    var currentBellFollowsTreble: Bool = false  // is the current bell following treble?
    var currentChangeNumber: Int = 0    // how many changes into current place bell?
    var currentPlaceBell: Int = 1   // place bell that selected bell is processing.
    
    var currentTrebleChecking: Bool = true // enable row 2 use, check for treble in front.
    var saveSender: UIButton = UIButton()   // Button the user just pressed.
    
    var buttonDownDetected: Bool = false // set true when buttonDown occurs.
    var longPressDetected: Bool = false
    var bobRequested: Bool = false
    var singleRequested: Bool = false
    var callActive: Bool = false


    
    
    
//    var currentBellArray: [Int] = [0]
//    var currentBellArrayIndex: Int = 0
//    var bellCount: Int = 4  // Number of bells in method.
//    var selectedBell = 1    // Actual Number of bell selected by user.
//    var buttonStarted: Int = 1
    
    // Save UIButton data in array.
    // Entry zero is a dummy entry, so bell 1 (treble) is saveButrtonArray[1].
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
        
        setOrientation()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
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
        
//        saveButtonArray[0].isEnabled = true
        
        bobButton.isEnabled = false
        singleButton.isEnabled = false
        
        startMethod()

        print("viewDidLoad: end")
        print("----------")
        
    }
    
    //------------------------------------------------------------------------------------------------
    // See what the user changed - stage or method.
    //------------------------------------------------------------------------------------------------
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        var bellCount: Int
        print("----------")
        print("pickerview: component", component, "row", row)
        // Stage name changed. Reload list of methods
        if component == 0 {
            let stageBellCount = stageFinder.findStageBells(requestStage: row)
            print("pickerView: bellCount", stageBellCount)
            
            // Make sure selected bell is not too high for this stage.
            if currentSelectedBell > stageBellCount {
                currentSelectedBell = stageBellCount
            }
            
            currentBellSequence = String("12345678".prefix(stageBellCount))
//            bellSequence.text = currentBellSequence
            
            // Disable buttons above new stage.
            button5.isEnabled = true
            button6.isEnabled = true
            button7.isEnabled = true
            button8.isEnabled = true
            if currentTrebleChecking == false {
                button5t.isEnabled = true
                button6t.isEnabled = true
                button7t.isEnabled = true
                button8t.isEnabled = true
            }
            if stageBellCount < 8 {
                button8.isEnabled = false
                button8t.isEnabled = false
            }
            if stageBellCount < 7 {
                button7.isEnabled = false
                button7t.isEnabled = false
            }
            if stageBellCount < 6 {
                button6.isEnabled = false
                button6t.isEnabled = false
            }
            if stageBellCount < 5 {
                button5.isEnabled = false
                button5t.isEnabled = false
            }
            
            print("pickerView: reloadComponent(1)")
            pickerView.reloadComponent(1)
            self.pickerView.selectRow(0, inComponent: 1, animated: true)
//        }
//        else {
//            // Method changed.
        }
            
        startMethod()
            
        
    }
    
    //--------------------
    // (re)start a method. Get method details, reset global variables, reset screen.
    //--------------------
    func startMethod() {

        let currentStage = pickerView.selectedRow(inComponent: 0)
        let currentMethod = pickerView.selectedRow(inComponent: 1)
        
        currentMethodData = methodFinder.findMethodData(requestStage: currentStage, requestRow: currentMethod)
        
        currentMethodArray = currentMethodData.methodArray
        
        currentBellPosition = currentSelectedBell
        
        bellSequence.text = currentBellSequence
        
        bobButton.isEnabled = currentMethodData.bobValid
        singleButton.isEnabled = currentMethodData.singleValid
        
//        self.showCurrentPlace.textColor = UIColor.black
//        self.showCurrentPlace.text = "Place Bell: " + String(currentSelectedBell)
        self.showCurrentPlace.text = currentMethodData.methodStructure
        
        self.showHandOrBack.text = "Handstroke next"
        
        setAllYellow()
        
        if currentSelectedBell < 100 {
            saveButtonArray[currentSelectedBell].backgroundColor = UIColor.green
        } else {
            saveButtonTArray[currentSelectedBell - 100].backgroundColor = UIColor.green

        }
        if currentSelectedBell == 2 {
            if currentTrebleChecking {
                button2t.backgroundColor = UIColor.green
                button2.backgroundColor = UIColor.yellow
            } else {
                button2t.backgroundColor = UIColor.green
            }
        }
        
//        self.showCurrentPlace.textColor = UIColor.black
        bobButton.backgroundColor = UIColor.clear
        singleButton.backgroundColor = UIColor.clear
        
        let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentStage, requestRow: currentMethod)
        
        bobButton.isEnabled = bobValid
        singleButton.isEnabled = singleValid
        
    }
    
    //---------------------------------------------------------------------
//    func loadArray(bellChosen: Int) {
//
//        let currentStage = pickerView.selectedRow(inComponent: 0)
//        let currentMethod = pickerView.selectedRow(inComponent: 1)
//
//        currentBellArray = methodFinder.findBellArray(requestStage: currentStage, requestRow: currentMethod, requestBell: bellChosen)
//
//        currentBellArrayIndex = 2
//        print("loadArray:", currentBellArray, currentBellArrayIndex)
//
//    }
//
    //------------------------------------------------------------------------------------------
    func setAllYellow() {
        button1.backgroundColor = UIColor.yellow
        button2.backgroundColor = UIColor.yellow
        button3.backgroundColor = UIColor.yellow
        button4.backgroundColor = UIColor.yellow
        button5.backgroundColor = UIColor.yellow
        button6.backgroundColor = UIColor.yellow
        button7.backgroundColor = UIColor.yellow
        button8.backgroundColor = UIColor.yellow
        button2t.backgroundColor = UIColor.yellow
        button3t.backgroundColor = UIColor.yellow
        button4t.backgroundColor = UIColor.yellow
        button5t.backgroundColor = UIColor.yellow
        button6t.backgroundColor = UIColor.yellow
        button7t.backgroundColor = UIColor.yellow
        button8t.backgroundColor = UIColor.yellow
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
            followTreble.setTitleColor(UIColor.black, for: .normal)
            button2t.isEnabled = true
            button3t.isEnabled = true
            button4t.isEnabled = true
            button5t.isEnabled = true
            button6t.isEnabled = true
            button7t.isEnabled = true
            button8t.isEnabled = true
            
            if currentMethodData.bellCount < 8 {
                button8.isEnabled = false
                button8t.isEnabled = false
            }
            if currentMethodData.bellCount < 7 {
                button7.isEnabled = false
                button7t.isEnabled = false
            }
            if currentMethodData.bellCount < 6 {
                button6.isEnabled = false
                button6t.isEnabled = false
            }
            if currentMethodData.bellCount < 5 {
                button5.isEnabled = false
                button5t.isEnabled = false
            }
            
            for i in 2...8 {
                if saveButtonTArray[i].backgroundColor == UIColor.green {
                    saveButtonArray[i].backgroundColor = UIColor.yellow
                }
            }
            
        } else {
            print("trebleOption: check treble now inactive")
            currentTrebleChecking = false
            followTreble.setTitleColor(UIColor.gray, for: .normal)
            button2t.isEnabled = false
            button3t.isEnabled = false
            button4t.isEnabled = false
            button5t.isEnabled = false
            button6t.isEnabled = false
            button7t.isEnabled = false
            button8t.isEnabled = false
            
            for i in 2...8 {
                if saveButtonTArray[i].backgroundColor != UIColor.yellow
                {
                    saveButtonArray[i].backgroundColor = saveButtonTArray[i].backgroundColor
                    if saveButtonTArray[i].backgroundColor != UIColor.green {
                        saveButtonTArray[i].backgroundColor = UIColor.yellow
                    }
                }
            }
        }
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
                longPressDetected = true
            }
        }
    }
    
    //------------------------------------------------------------------------------------------------
    @IBAction func buttonDown(_ sender: UIButton) {
 
        print("buttonDown: sender=", sender.tag)
        saveSender = sender
        buttonDownDetected = true
//        self.showCurrentPlace.textColor = UIColor.black
        setAllYellow()
    }
    
    //------------------------------------------------------------------------------------------------
    @IBAction func buttonPressed(_ sender: UIButton) {
        
//        var callStarted: Bool = false
//        var callEnded: Bool = false
//        var followsTreble: Bool = false
        var correctBellPosition: Int
        
        print("---------button Pressed-----------")
        print("callStarted#3", callActive)

        
        let currentStage = pickerView.selectedRow(inComponent: 0)
        let currentMethod = pickerView.selectedRow(inComponent: 1)
                
        print("longPressDetected", longPressDetected, buttonDownDetected, currentPlaceBell)
        
        if longPressDetected {
            if buttonDownDetected {
                
//                saveButtonArray[currentPlaceBell].layer.borderWidth = 0

                currentSelectedBell = sender.tag
                if currentSelectedBell > 100 {
                    currentSelectedBell = currentSelectedBell - 100
                }
                
                currentBellPosition = currentSelectedBell
                currentPlaceBell = currentSelectedBell
                currentBellSequence = String("12345678".prefix(currentMethodData.bellCount))
                currentChangeNumber = 0
                
                saveButtonTArray[currentPlaceBell].layer.borderWidth = 0
                saveButtonArray[currentPlaceBell].layer.borderWidth = 2
                saveButtonArray[currentPlaceBell].layer.borderColor = UIColor.black.cgColor

//                if currentSelectedBell > 100 {
//                    currentSelectedBell = selectedBell - 100
//                }
//                if selectedBell > stageBells {
//                    print("Invalid long press, sender", sender.tag, "max", stageBells)
//                    selectedBell = stageBells
//                }
//                print("longPress, bellChosen", selectedBell, "methodNumber", currentMethod)
//                loadArray(bellChosen: currentSelectedBell)
                
                startMethod()
            }
            longPressDetected = false
            
            
        // Check if correct button was pressed.
        } else {
            print("callStarted#1", callActive)
            if callActive {
                
                print("ViewController: reset bob/single buttons.")
                    
                let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentStage, requestRow: currentMethod)
                    
                bobButton.isEnabled = bobValid
                singleButton.isEnabled = singleValid
                bobRequested = false
                singleRequested = false
                bobButton.backgroundColor = UIColor.clear
                singleButton.backgroundColor = UIColor.clear
            }
            
            let (newMethodArray, newBellPosition, newFollowsTreble, newBellSequence, newPlaceBell, callStarted) = methodFinder.findNextPosition(currentMethodArray: currentMethodArray, currentUserBell: currentSelectedBell, currentBellPosition: currentBellPosition, currentChangeNumber: currentChangeNumber, currentBellSequence: currentBellSequence, currentPlaceBell: currentPlaceBell, bobRequested: bobRequested, singleRequested: singleRequested)
            
            callActive = callStarted
            correctBellPosition = newBellPosition
//            if (newFollowsTreble && currentTrebleChecking) {
//                correctBellPosition = correctBellPosition + 100
//            }
            print("buttonpressed", sender.tag, "correct button", correctBellPosition, "follow treble", newFollowsTreble)
            
            bellSequence.text = newBellSequence
            currentBellSequence = newBellSequence
            currentMethodArray = newMethodArray
            
            if ((newFollowsTreble == false && sender.tag == correctBellPosition)
                || (newFollowsTreble && sender.tag - 100 == correctBellPosition)
                || (currentTrebleChecking == false && sender.tag == correctBellPosition))  {
                self.setButtonColour(senderCode: sender, colourWanted: UIColor.green)
                if newFollowsTreble {
                    setButtonColour(senderCode: saveButtonTArray[correctBellPosition], colourWanted: UIColor.green)
                }
            }
            else {
                self.setButtonColour(senderCode: sender, colourWanted: UIColor.red)
                
                // Set correct button to green.
                if newFollowsTreble {
                    setButtonColour(senderCode: saveButtonTArray[correctBellPosition], colourWanted: UIColor.green)
                } else {
                    setButtonColour(senderCode: saveButtonTArray[correctBellPosition], colourWanted: UIColor.green)
                }
            }
            
            if newPlaceBell != 0 {
                
                print("new place bell was", currentPlaceBell, "now", newPlaceBell)
                saveButtonArray[currentPlaceBell].layer.borderWidth = 0
//                saveSender.layer.borderColor = UIColor.black.cgColor
                saveButtonArray[newPlaceBell].layer.borderWidth = 2
                saveButtonArray[newPlaceBell].layer.borderColor = UIColor.black.cgColor
                
                currentPlaceBell = newPlaceBell
//                self.showCurrentPlace.text = "Place Bell: " + String(currentPlaceBell)
//                self.showCurrentPlace.textColor = UIColor.red
                currentChangeNumber = 0
                currentMethodArray = currentMethodData.methodArray
            } else {
                currentChangeNumber = currentChangeNumber + 1
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
            
            if self.showHandOrBack.text == "Handstroke next" {
                self.showHandOrBack.text = "Backstroke next"
            } else {
                self.showHandOrBack.text = "Handstroke next"
            }
            

            
            currentBellPosition = newBellPosition
            buttonDownDetected = false
            print("callStarted#2", callActive)

            print("End of Button pressed")
        }
    }
    
    //----------------------------------------------------------------------------
    func setButtonColour(senderCode: UIButton, colourWanted: UIColor) {
        (senderCode as UIButton).backgroundColor = colourWanted
        (senderCode as UIButton).titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            (senderCode as UIButton).titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

