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
    
    var player: AVAudioPlayer!
    
    var methodFinder = MethodFinder()
    var stageFinder = StageFinder()
        
    @IBOutlet weak var pickerView: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("numberOfComponents: 2")
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
        print("numberOfRowsInComponent:", component, returnRowsInComponent)
        return returnRowsInComponent
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let returnStageName = stageFinder.findStageName(requestStage: row)
            print("titleForRow:", component, row, "->", returnStageName)
            return returnStageName
        } else {
            let currentStage = pickerView.selectedRow(inComponent: 0)
            
            let returnMethodName = methodFinder.findName(requestStage: currentStage, requestRow: row)
            print("titleForRow:", component, row, "->", returnMethodName)
            return returnMethodName
        }
        
    }
    
    // Global Variables are not (allegedly) good.
    // Here they are.
    var currentBellArray: [Int] = [0]
    var currentBellArrayIndex: Int = 0
    var selectedBell = 1    // Actual Number of bell selected by user.
    var longPressDetected: Bool = false
    var buttonStarted: Int = 1
    var saveSender: UIButton = UIButton()

//    var saveSender:
    
    ////    var methodName = " "    // Text name of current method.
    //
    //    var bellCount = 6   // Number of bells in current method, e.g. 5 if doubles.
    ////    var selectedMethodNumber = 0    // Selected method number in list of methods, start from zero.
    //    var placeBellList = ["1","2","3","4","5","6","7","8"]   // List of number to display on second pickerview.
    //
    //    var placeBellArray: [Int] = [1,1,2,3,4,5,6,6,5,4,3,2,1,901] // Array being used for current place bell.
    //    var placeBellArrayIndex: Int = 2    // Indexer for placeBellArray.
    //    var selectedBell = 1    // Actual Number of bell selected by user.
    //    var currentPlaceBell = 1 // Place bell now, starts off as selected bell.
    //    var newPlaceBell: Int = 0   // non-zero if new place bell found.
    //    var correctBell :Int = 0    // Bell number (1-12) that should be pressed.
    //
    //    var previousButtonPressed: Int = 0
    //    var previousCorrectButton: Int = 0
    //
    //    var bobRequested :Bool = false
    //    var singleRequested :Bool = false
    //    var bobValid :Bool = false
    //    var singleValid :Bool = false
    //    var callStarted: Bool = false
    //    var callEnded: Bool = false
    //    var mp3Name: String = ""
    //
    //
    //    var handstroke :Bool = false
    //    var checkTreble :Bool = true
    
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
    @IBOutlet weak var showHandOrBack: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("viewDidLoad: start")
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        
        
        bobButton.isEnabled = false
        singleButton.isEnabled = false
        
//        print("viewDidLoad: set component 0 to row 1")
//        self.pickerView.selectRow(1, inComponent:0, animated:false)
//        print("viewDidLoad: reloadComponent(1)")
//        self.pickerView.reloadComponent(1)
        
        loadArray(bellChosen: selectedBell)
        
        print("viewDidLoad: end")
        print("----------")


        
    }
    
    //------------------------------------------------------------------------------------------------
    // See what the user changed - stage or method.
    //------------------------------------------------------------------------------------------------
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var bellCount: Int
        print("----------")
        print("pickerview: component", component, "row", row)
        // Stage name changed. Reload list of methods
        if component == 0 {
            bellCount = stageFinder.findStageBells(requestStage: row)
            print("pickerView: bellCount", bellCount)
            if selectedBell > bellCount {
                selectedBell = bellCount
            }
            button5.isEnabled = true
            button6.isEnabled = true
            button7.isEnabled = true
            button8.isEnabled = true
            button5t.isEnabled = true
            button6t.isEnabled = true
            button7t.isEnabled = true
            button8t.isEnabled = true
            if bellCount < 8 {
                button8.isEnabled = false
                button8t.isEnabled = false
            }
            if bellCount < 7 {
                button7.isEnabled = false
                button7t.isEnabled = false
            }
            if bellCount < 6 {
                button6.isEnabled = false
                button6t.isEnabled = false
            }
            if bellCount < 5 {
                button5.isEnabled = false
                button5t.isEnabled = false
            }

            print("pickerView: reloadComponent(1)")
            pickerView.reloadComponent(1)
            self.pickerView.selectRow(0, inComponent: 1, animated: true)
        }
        else {
            // Method changed.
            
            let currentStage = pickerView.selectedRow(inComponent: 0)
            let currentMethod = pickerView.selectedRow(inComponent: 1)
            
            let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentStage, requestRow: currentMethod)
            
            bobButton.isEnabled = bobValid
            singleButton.isEnabled = singleValid
            
        }
        loadArray(bellChosen: selectedBell)
        resetScreen()
    }
    
    //--------------------
    // Reset screen for change of method.
    //--------------------
    
    func resetScreen() {
        
        self.showCurrentPlace.textColor = UIColor.black
        self.showCurrentPlace.text = "Place Bell: " + String(selectedBell)
        
        // Reset all buttons to yellow and colour of Place Bell message. Reset bob/single buttons.
        // Bell 2 obviously starts behind treble.
        setAllYellow()
        //        previousCorrectButton = currentPlaceBell
        switch selectedBell {
        case 1: button1.backgroundColor = UIColor.green; //print("P1")
            
        case 2: button2t.backgroundColor = UIColor.green; //print("P2T")
            if followTreble.currentTitleColor == UIColor.gray {
            button2.backgroundColor = UIColor.green
            button2t.backgroundColor = UIColor(named: "LightGreen")
        }
            
        case 3: button3.backgroundColor = UIColor.green; //print("P3")
        case 4: button4.backgroundColor = UIColor.green; //print("P4")
        case 5: button5.backgroundColor = UIColor.green; //print("P5")
        case 6: button6.backgroundColor = UIColor.green; //print("P6")
        case 7: button7.backgroundColor = UIColor.green; //print("P7")
        case 8: button8.backgroundColor = UIColor.green; //print("P8")
        default:button1.backgroundColor = UIColor.yellow; print("ERROR setting initial green button")
        }
        
        self.showCurrentPlace.textColor = UIColor.black
        bobButton.backgroundColor = UIColor.clear
        singleButton.backgroundColor = UIColor.clear
        

        let currentStage = pickerView.selectedRow(inComponent: 0)
        let currentMethod = pickerView.selectedRow(inComponent: 1)
        
        let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentStage, requestRow: currentMethod)
        
        bobButton.isEnabled = bobValid
        singleButton.isEnabled = singleValid
        
    }
    
    //---------------------------------------------------------------------
    func loadArray(bellChosen: Int) {
        
        let currentStage = pickerView.selectedRow(inComponent: 0)
        let currentMethod = pickerView.selectedRow(inComponent: 1)
        
        currentBellArray = methodFinder.findBellArray(requestStage: currentStage, requestRow: currentMethod, requestBell: bellChosen)
        
        currentBellArrayIndex = 2
        print("loadArray:", currentBellArray, currentBellArrayIndex)
        
    }
    
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
        } else {
            bobButton.backgroundColor = UIColor.green
            singleButton.backgroundColor = UIColor.clear
        }
        //        }
        print("bobButton: bobButton", bobButton.backgroundColor as Any, "singleButton", singleButton.backgroundColor as Any)
    }
    //------------------------------------------------------------------------------------------------
    @IBAction func singleButton(_ sender: UIButton) {
        //        print("SINGLE button pressed, valid = ", singleValid)
        if singleButton.backgroundColor == UIColor.green  {
            singleButton.backgroundColor = UIColor.clear
        } else {
            singleButton.backgroundColor = UIColor.green
            bobButton.backgroundColor = UIColor.clear
        }
        print("singleButton: bobButton", bobButton.backgroundColor as Any, "singleButton", singleButton.backgroundColor as Any)
    }
    //------------------------------------------------------------------------------------------------
    @IBAction func trebleOption(_ sender: UIButton) {
        print("trebleOption: started")
        longPressDetected = false
        
        if followTreble.currentTitleColor == UIColor.gray {
            followTreble.setTitleColor(UIColor.black, for: .normal)
            print("trebleOption: check treble now active")
            button2t.isEnabled = true
            button3t.isEnabled = true
            button4t.isEnabled = true
            button5t.isEnabled = true
            button6t.isEnabled = true
            button7t.isEnabled = true
            button8t.isEnabled = true
            
            if (button2.backgroundColor == UIColor.green && button2t.backgroundColor == UIColor(named: "LightGreen")) {
                button2.backgroundColor = UIColor.yellow
                button2t.backgroundColor = UIColor.green
            }
            if (button3.backgroundColor == UIColor.green && button3t.backgroundColor == UIColor(named: "LightGreen")) {
                button3.backgroundColor = UIColor.yellow
                button3t.backgroundColor = UIColor.green
                
            }
            if (button4.backgroundColor == UIColor.green && button4t.backgroundColor == UIColor(named: "LightGreen")) {
                button4.backgroundColor = UIColor.yellow
                button4t.backgroundColor = UIColor.green

            }
            if (button5.backgroundColor == UIColor.green && button5t.backgroundColor == UIColor(named: "LightGreen")) {
                button5.backgroundColor = UIColor.yellow
                button5t.backgroundColor = UIColor.green

            }
            if (button6.backgroundColor == UIColor.green && button6t.backgroundColor == UIColor(named: "LightGreen")) {
                button6.backgroundColor = UIColor.yellow
                button6t.backgroundColor = UIColor.green

            }
            if (button7.backgroundColor == UIColor.green && button7t.backgroundColor == UIColor(named: "LightGreen")) {
                button7.backgroundColor = UIColor.yellow
                button7t.backgroundColor = UIColor.green

            }
            if (button8.backgroundColor == UIColor.green && button8t.backgroundColor == UIColor(named: "LightGreen")) {
                button8.backgroundColor = UIColor.yellow
                button8t.backgroundColor = UIColor.green

            }
        }
        else {
            
            followTreble.setTitleColor(UIColor.gray, for: .normal)
            print("trebleOption: check treble now inactive")
            button2t.isEnabled = false
            button3t.isEnabled = false
            button4t.isEnabled = false
            button5t.isEnabled = false
            button6t.isEnabled = false
            button7t.isEnabled = false
            button8t.isEnabled = false
            
            if button2t.backgroundColor == UIColor.green {
                button2t.backgroundColor = UIColor(named: "LightGreen")
                button2.backgroundColor = UIColor.green
            }
            if button3t.backgroundColor == UIColor.green {
                button3t.backgroundColor = UIColor(named: "LightGreen")
                button3.backgroundColor = UIColor.green
            }
            if button4t.backgroundColor == UIColor.green {
                button4t.backgroundColor = UIColor(named: "LightGreen")
                button4.backgroundColor = UIColor.green
            }
            if button5t.backgroundColor == UIColor.green {
                button5t.backgroundColor = UIColor(named: "LightGreen")
                button5.backgroundColor = UIColor.green
            }
            if button6t.backgroundColor == UIColor.green {
                button6t.backgroundColor = UIColor(named: "LightGreen")
                button6.backgroundColor = UIColor.green
            }
            if button7t.backgroundColor == UIColor.green {
                button7t.backgroundColor = UIColor(named: "LightGreen")
                button7.backgroundColor = UIColor.green
            }
            if button8t.backgroundColor == UIColor.green {
                button8t.backgroundColor = UIColor(named: "LightGreen")
                button8.backgroundColor = UIColor.green
            }
        }
    }
    //------------------------------------------------------------------------------------------------
    @IBAction func longPressSeen(_ sender: UILongPressGestureRecognizer) {
        
//        print("longPressSeen, senderstate", sender.state)
//        print("Sender.mindur", sender.minimumPressDuration)
//        print(UIGestureRecognizer.State.self)
        
        if (sender.state == UIGestureRecognizer.State.ended) {
            longPressDetected = true
            
//            saveSender.tintColor = UIColor.red //-------------------------------

            print("Long press Ended")
        } else if (sender.state == UIGestureRecognizer.State.began) {
            print("Long press detected.") // buttonStarted=", buttonStarted)
//            saveSender.backgroundColor = UIColor(named: "Moss")
            saveSender.layer.borderWidth = 2
            saveSender.layer.borderColor = UIColor.red.cgColor
            
//            switch buttonStarted {
//            case 1: self.setButtonColour(senderCode: button1, colourWanted: UIColor.blue)
//            case 2: self.setButtonColour(senderCode: button2, colourWanted: UIColor.blue)
//            case 3: self.setButtonColour(senderCode: button3, colourWanted: UIColor.blue)
//            case 4: self.setButtonColour(senderCode: button4, colourWanted: UIColor.blue)
//            case 5: self.setButtonColour(senderCode: button5, colourWanted: UIColor.blue)
//            case 6: self.setButtonColour(senderCode: button6, colourWanted: UIColor.blue)
//            case 7: self.setButtonColour(senderCode: button7, colourWanted: UIColor.blue)
//            case 8: self.setButtonColour(senderCode: button8, colourWanted: UIColor.blue)
//            case 102: self.setButtonColour(senderCode: button2t, colourWanted: UIColor.blue)
//            case 103: self.setButtonColour(senderCode: button3t, colourWanted: UIColor.blue)
//            case 104: self.setButtonColour(senderCode: button4t, colourWanted: UIColor.blue)
//            case 105: self.setButtonColour(senderCode: button5t, colourWanted: UIColor.blue)
//            case 106: self.setButtonColour(senderCode: button6t, colourWanted: UIColor.blue)
//            case 107: self.setButtonColour(senderCode: button7t, colourWanted: UIColor.blue)
//            case 108: self.setButtonColour(senderCode: button8t, colourWanted: UIColor.blue)
//            default: break
//            }

        }
    }
    
    //------------------------------------------------------------------------------------------------
    @IBAction func buttonDown(_ sender: UIButton) {
//        print("saveSender at start of buttonDown", saveSender)
//        saveSender.tintColor = UIColor.systemPurple
//        sender.tintColor = UIColor.red
//        var saveSender: UIButton = UIButton()
//        sender.backgroundColor = UIColor.purple
//        let saveSenderBackgroundColor = sender.backgroundColor
//        print(saveSender.tintColor!)
//        saveSender.tintColor = UIColor.red
//        print("saveSenderBackgroundColor", saveSenderBackgroundColor as Any)
        print("buttonDown: sender=", sender.tag)
        saveSender = sender

//        buttonStarted = sender.tag
        setAllYellow()
    }
    
    
    //------------------------------------------------------------------------------------------------
//    @IBAction func buttonPressStarted(_ sender: UIButton) {
//        buttonStarted = sender.tag
//        print("buttonPressStarted: button", buttonStarted)
//    }
    //------------------------------------------------------------------------------------------------
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        var callStarted: Bool = false
        var callEnded: Bool = false
        var followsTreble: Bool = false
        
        print("---------button Pressed-----------")
        
        let currentStage = pickerView.selectedRow(inComponent: 0)
        let currentMethod = pickerView.selectedRow(inComponent: 1)
        
        print("longPressDetected", longPressDetected)
        
        if longPressDetected {
            
            let stageBells = stageFinder.findStageBells(requestStage: currentStage)
            
            
            saveSender.layer.borderWidth = 0
//            saveSender.layer.borderColor = UIColor.red.cgColor
            
            selectedBell = sender.tag
            if selectedBell > 100 {
                selectedBell = selectedBell - 100
            }
            if selectedBell > stageBells {
                print("Invalid long press, sender", sender.tag, "max", stageBells)
                selectedBell = stageBells
            }
            print("longPress, bellChosen", selectedBell, "methodNumber", currentMethod)
            loadArray(bellChosen: selectedBell)
            resetScreen()
            longPressDetected = false
            
        } else {
            
            var correctBell = currentBellArray[currentBellArrayIndex]
            print("buttonpressed", sender.tag, "correct button", correctBell)
            
            if followTreble.currentTitleColor == UIColor.gray && correctBell > 100 && correctBell < 200 {
                correctBell = correctBell - 100
                followsTreble = true
                print("...not checking treble, correct bell now", correctBell)
            }
            if correctBell > 850 {
                correctBell = correctBell - 850
            }
            if correctBell > 750 {
                correctBell = correctBell - 750
            }
            
            if sender.tag == correctBell {
                self.setButtonColour(senderCode: sender, colourWanted: UIColor.green)
                if followsTreble {
                    switch correctBell {
                    case 2:
                        self.setButtonColour(senderCode: button2t, colourWanted: UIColor(named: "LightGreen")!)
                    case 3:
                        self.setButtonColour(senderCode: button3t, colourWanted: UIColor(named: "LightGreen")!)
                    case 4:
                        self.setButtonColour(senderCode: button4t, colourWanted: UIColor(named: "LightGreen")!)
                    case 5:
                        self.setButtonColour(senderCode: button5t, colourWanted: UIColor(named: "LightGreen")!)
                    case 6:
                        self.setButtonColour(senderCode: button6t, colourWanted: UIColor(named: "LightGreen")!)
                    case 7:
                        self.setButtonColour(senderCode: button7t, colourWanted: UIColor(named: "LightGreen")!)
                    case 8:
                        self.setButtonColour(senderCode: button8t, colourWanted: UIColor(named: "LightGreen")!)
                    default:
                        break
                    }
                }
            }
            else {
                self.setButtonColour(senderCode: sender, colourWanted: UIColor.red)
                
                switch correctBell {
                case 1:
                    self.setButtonColour(senderCode: button1, colourWanted: UIColor.green)
                case 2:
                    self.setButtonColour(senderCode: button2, colourWanted: UIColor.green)
                case 3:
                    self.setButtonColour(senderCode: button3, colourWanted: UIColor.green)
                case 4:
                    self.setButtonColour(senderCode: button4, colourWanted: UIColor.green)
                case 5:
                    self.setButtonColour(senderCode: button5, colourWanted: UIColor.green)
                case 6:
                    self.setButtonColour(senderCode: button6, colourWanted: UIColor.green)
                case 7:
                    self.setButtonColour(senderCode: button7, colourWanted: UIColor.green)
                case 8:
                    self.setButtonColour(senderCode: button8, colourWanted: UIColor.green)
                case 102:
                    self.setButtonColour(senderCode: button2t, colourWanted: UIColor.green)
                case 103:
                    self.setButtonColour(senderCode: button3t, colourWanted: UIColor.green)
                case 104:
                    self.setButtonColour(senderCode: button4t, colourWanted: UIColor.green)
                case 105:
                    self.setButtonColour(senderCode: button5t, colourWanted: UIColor.green)
                case 106:
                    self.setButtonColour(senderCode: button6t, colourWanted: UIColor.green)
                case 107:
                    self.setButtonColour(senderCode: button7t, colourWanted: UIColor.green)
                case 108:
                    self.setButtonColour(senderCode: button8t, colourWanted: UIColor.green)
                    
                default:
                    button1.backgroundColor = UIColor.yellow
                }
                if followsTreble {
                    switch correctBell {
                    case 2:
                        self.setButtonColour(senderCode: button2t, colourWanted: UIColor(named: "LightGreen")!)
                    case 3:
                        self.setButtonColour(senderCode: button3t, colourWanted: UIColor(named: "LightGreen")!)
                    case 4:
                        self.setButtonColour(senderCode: button4t, colourWanted: UIColor(named: "LightGreen")!)
                    case 5:
                        self.setButtonColour(senderCode: button5t, colourWanted: UIColor(named: "LightGreen")!)
                    case 6:
                        self.setButtonColour(senderCode: button6t, colourWanted: UIColor(named: "LightGreen")!)
                    case 7:
                        self.setButtonColour(senderCode: button7t, colourWanted: UIColor(named: "LightGreen")!)
                    case 8:
                        self.setButtonColour(senderCode: button8t, colourWanted: UIColor(named: "LightGreen")!)
                    default:
                        break
                    }
                    
                }
            }
            
            var bobRequested = false
            if bobButton.backgroundColor == UIColor.green {
                bobRequested = true
            }
            
            var singleRequested = false
            if singleButton.backgroundColor == UIColor.green {
                singleRequested = true
            }
            
            (currentBellArray, currentBellArrayIndex, callStarted, callEnded) = methodFinder.findNextPlace(requestStage: currentStage, requestRow: currentMethod, requestArray: currentBellArray, requestArrayIndex: currentBellArrayIndex, bobRequested: bobRequested, singleRequested: singleRequested)
            
            if callStarted {
                var mp3Name: String
                print("ViewController: Say Bob or Single")
                bobButton.isEnabled = false
                singleButton.isEnabled = false
                if bobRequested == true {
                    mp3Name = "bob"
                } else {
                    mp3Name = "single"
                }
                let url1 = Bundle.main.url(forResource: mp3Name, withExtension: "mp3")
                player = try! AVAudioPlayer(contentsOf: url1!)
                player.play()
                
            }
            if callEnded == true {
                print("ViewController: Call Ended, enable bob/single buttons.")
                
                let (bobValid, singleValid) = methodFinder.findValidCalls(requestStage: currentStage, requestRow: currentMethod)
                
                bobButton.isEnabled = bobValid
                singleButton.isEnabled = singleValid
                bobRequested = false
                singleRequested = false
                bobButton.backgroundColor = UIColor.clear
                singleButton.backgroundColor = UIColor.clear
            }
            
            if self.showHandOrBack.text == "Handstroke" {
                self.showHandOrBack.text = "Backstroke"
            } else {
                self.showHandOrBack.text = "Handstroke"
            }
            
            self.showCurrentPlace.textColor = UIColor.black
            if currentBellArrayIndex == 2 {
                self.showCurrentPlace.text = "Place Bell: " + String(String(currentBellArray[0]).first!)
                if currentBellArray[0] <= 12 {
                    self.showCurrentPlace.textColor = UIColor.red
                }
            }
            print("End of Button pressed, next correct button", currentBellArray[currentBellArrayIndex])
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

