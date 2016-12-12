//
//  ViewController.swift
//  Calculator
//
//  Created by Miguel Garcia on 11/14/16.
//  Copyright © 2016 GCC. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    @IBOutlet weak var button13: UIButton!
    @IBOutlet weak var button14: UIButton!
    @IBOutlet weak var button15: UIButton!
    @IBOutlet weak var button16: UIButton!
    @IBOutlet weak var button17: UIButton!
    @IBOutlet weak var button18: UIButton!
    @IBOutlet weak var button19: UIButton!
    @IBOutlet weak var button20: UIButton!
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var displayDescription: UILabel!
    
    private var brain: CalculatorBrain = CalculatorBrain()
    private var userIsInTheMiddleOfTyping: Bool = false
    private var previousOp = "?"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(CalculatorViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
            button1.isHidden = false; button2.isHidden = false;
            button3.isHidden = false; button4.isHidden = false;
            button5.isHidden = false; button6.isHidden = false;
            button7.isHidden = false; button8.isHidden = false;
            button9.isHidden = false; button10.isHidden = false;
            button11.isHidden = false; button12.isHidden = false;
            button13.isHidden = false; button14.isHidden = false;
            button15.isHidden = false; button16.isHidden = false;
            button17.isHidden = false; button18.isHidden = false;
            button19.isHidden = false; button20.isHidden = false;
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
        {
            button1.isHidden = true; button2.isHidden = true;
            button3.isHidden = true; button4.isHidden = true;
            button5.isHidden = true; button6.isHidden = true;
            button7.isHidden = true; button8.isHidden = true;
            button9.isHidden = true; button10.isHidden = true;
            button11.isHidden = true; button12.isHidden = true;
            button13.isHidden = true; button14.isHidden = true;
            button15.isHidden = true; button16.isHidden = true;
            button17.isHidden = true; button18.isHidden = true;
            button19.isHidden = true; button20.isHidden = true;
        }
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle! //1
        if (userIsInTheMiddleOfTyping && digit != ".") ||
            (digit == "." && (display.text!.range(of: ".") == nil)){
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            if digit == "." {
                display.text =  "0" + digit
            } else {
                display.text = digit
            }
        }
        previousOp = "?"
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue : Double? {
        get {
            //return Double(display.text!)!
            if let text = display.text {
                return NumberFormatter().number(from: text)?.doubleValue
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 6
                display.text = formatter.string(from: NSNumber(value: value))
                displayDescription.text = brain.description + (brain.isPartialResult ? " ..." : " =")
            } else {
                display.text = "0"
                displayDescription.text = "0"
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton){
        if ( (previousOp != "+") && (previousOp != "-") &&
            (previousOp != "×") && (previousOp != "÷") &&
            (previousOp != "xⁿ") && (previousOp != "%")){
            if userIsInTheMiddleOfTyping {
                brain.setOperand(operand: displayValue!)
                userIsInTheMiddleOfTyping = false
            }
            if let matematicalSymbol = sender.currentTitle {
                brain.performOperation(symbol: matematicalSymbol)
                previousOp = matematicalSymbol

            }
            displayValue = brain.result
        }
    }
    
    var saveProgram: CalculatorBrain.PropertyList?
    
    @IBAction func clearButton() {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        displayValue = nil
    }
    
    @IBAction func setValueOfVariable() {
        userIsInTheMiddleOfTyping = false
        brain.variableValues["m"] = displayValue!
        saveProgram = brain.program
        brain.program = saveProgram!
        displayValue = brain.result
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        let variable = sender.currentTitle!
        previousOp = "m"
        brain.setOperand(variableName: variable)
        displayValue = brain.result
    }
    
    @IBAction func Undo() {
        if userIsInTheMiddleOfTyping {
            var textCurrentlyInDisplay = display.text!
            textCurrentlyInDisplay.remove(at:
                textCurrentlyInDisplay.index(before:
                    textCurrentlyInDisplay.endIndex))
            display.text = textCurrentlyInDisplay
            if textCurrentlyInDisplay.isEmpty {
                userIsInTheMiddleOfTyping = false
            }
        }
        else {
            brain.removeProgramComputation()
            saveProgram = brain.program
            brain.program = saveProgram!
            displayValue = brain.result
            
        }
    }
}
