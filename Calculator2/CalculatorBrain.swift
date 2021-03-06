//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Miguel Garcia on 11/14/16.
//  Copyright © 2016 GCC. All rights reserved.
//

import Foundation

class CalculatorBrain{
    
    private var accumulator: Double = 0.0
    
    private var theValueOnHold = 0.0
    
    private var descriptionAccumulator = "0"
    
    var result: Double{ get{ return accumulator } }
    
    var isPartialResult: Bool = false
    
    var variableValues = [String: Double]()
    
    var description: String{
        get{
            if pending == nil{
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    enum Operation{
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String)
        case nullaryOperation(() -> Double, () -> String)
        case Equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : .Constant(M_PI),
        "e" : .Constant(M_E),
        "Rand": .nullaryOperation({drand48()}, { "rand" }),
        "±" : .UnaryOperation({ -$0}, { "-(" + $0 + ")" }),
        "√x" : .UnaryOperation(sqrt, {"²√(" + $0 + ")"}),
        "sin" : .UnaryOperation(sin, { "sin(" + $0 + ")" }),
        "cos" : .UnaryOperation(cos, { "cos(" + $0 + ")" }),
        "tan" : .UnaryOperation(tan, { "tan(" + $0 + ")" }),
        "sinh" : .UnaryOperation(sinh, { "sinh(" + $0 + ")" }),
        "cosh" : .UnaryOperation(cosh, { "cosh(" + $0 + ")" }),
        "tanh" : .UnaryOperation(tanh, { "tanh(" + $0 + ")" }),
        "ln" : .UnaryOperation(log, { "ln(" + $0 + ")" }),
        "log" : .UnaryOperation(log10, { "log(" + $0 + ")" }),
        "10ⁿ": .UnaryOperation({pow(10,$0)}, { "(10)^" + $0 }),
        "eⁿ": .UnaryOperation({pow(M_E,$0)}, { "(e)^" + $0 }),
        "x⁻¹": .UnaryOperation({1/$0}, { "(" + $0 + ")⁻¹" }),
        "x²": .UnaryOperation({$0 * $0}, { "(" + $0 + ")²" }),
        "xⁿ": .BinaryOperation({pow($0,$1)}, { "(" + $0 + ")^" + $1}),
        "+" : .BinaryOperation({$0 + $1}, { $0 + " + " + $1 }),
        "−" : .BinaryOperation({$0 - $1}, { $0 + " - " + $1 }),
        "×" : .BinaryOperation({$0 * $1}, { $0 + " × " + $1 }),
        "÷" : .BinaryOperation({$0 / $1}, { $0 + " ÷ " + $1 }),
        "%" : .BinaryOperation({$0.truncatingRemainder(dividingBy: $1)}, { $0 + " % " + $1 }),
        "=" : .Equals
    ]
    
    struct PendingBinaryOperationInfo {
        var firstOperand: Double
        var binaryFunction: (Double, Double) -> Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    private var pending: PendingBinaryOperationInfo?    //2
    
    private var internalProgram = [AnyObject]()
    
    func removeProgramComputation() {
        if !internalProgram.isEmpty{
            internalProgram.removeLast()
        }
    }
    
    func performOperation(symbol: String){
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue()
            case .BinaryOperation(let function, let descriptionFunction):
                isPartialResult = true
                executePendingbinaryOperation()
                pending = PendingBinaryOperationInfo(firstOperand: accumulator,
                                                     binaryFunction: function,
                                                     descriptionFunction: descriptionFunction,
                                                     descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingbinaryOperation()
            }
        }
    }
    
    func executePendingbinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand,
                                                                  descriptionAccumulator)
            pending = nil
            isPartialResult = false
        }
    }
    
    func setOperand(operand: Double){
        accumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(variableName: String){
        accumulator = variableValues[variableName] ?? 0
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    func setOperand(_ variableName: String, to variableNameValue: Double){
        variableValues[variableName] = variableNameValue
        accumulator = variableValues[variableName] ?? 0
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList{
        get{
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
            clear()
            if let arrayofOps = newValue as? [PropertyList] {
                for op in arrayofOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    }
                    else if let operand = op as? String {
                        if operations[operand] != nil {
                            performOperation(symbol: operand)
                        }
                        else{
                            setOperand(operand, to: theValueOnHold)
                        }
                    }
                }
            }
        }
    }
    
    func clear(){
        accumulator = 0.0
        descriptionAccumulator = "0"
        pending = nil
        if let valueOnHold = variableValues.removeValue(forKey:
            "m"){
            theValueOnHold = valueOnHold
        }
        internalProgram.removeAll()
    }
}
