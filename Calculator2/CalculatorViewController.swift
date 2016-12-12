//
//  ViewController.swift
//  Calculator
//
//  Created by Miguel Garcia on 11/14/16.
//  Copyright © 2016 GCC. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private var brain: CalculatorBrain = CalculatorBrain()
    private var userIsInTheMiddleOfTyping: Bool = false
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var displayDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue : Double? {
        get {
            //! optional: we have to account for every string passed
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
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let matematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: matematicalSymbol)
        }
        displayValue = brain.result
    }
    
    var saveProgram: CalculatorBrain.PropertyList?
    /*
    @IBAction func save() {
        saveProgram = brain.program
    }
    
    @IBAction func restore() {
        if saveProgram != nil {
            brain.program = saveProgram!
            displayValue = brain.result
        }
    }*/
    
    @IBAction func clearButton() {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        displayValue = nil
    }
    
    @IBAction func setValueOfVariable() {
        userIsInTheMiddleOfTyping = false
        brain.variableValues["M"] = displayValue!
        saveProgram = brain.program
        brain.program = saveProgram!
        displayValue = brain.result
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        let variable = sender.currentTitle!
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

