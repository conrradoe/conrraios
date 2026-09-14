//
//  OTPFieldView.swift
//  OTPFieldView
//
//  Created by Vaibhav Bhasin on 10/09/19.
//  Copyright © 2023 Vaibhav Bhasin. All rights reserved.
//

//    MIT License
//
//    Copyright (c) 2019 Vaibhav Bhasin
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import UIKit

@objc public protocol OTPFieldViewDelegate: class {
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool
    func enteredOTP(otp: String)
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool
}

@objc public enum DisplayType: Int {
    case circular
    case roundedCorner
    case square
    case diamond
    case underlinedBottom
}

/// Different input type for OTP fields.
@objc public enum KeyboardType: Int {
    case numeric
    case alphabet
    case alphaNumeric
}

@objcMembers public class OTPFieldView: UIView {
    
    /// Different display type for text fields.
    
    
    public var displayType: DisplayType = .circular
    public var fieldsCount: Int = 4
    public var otpInputType: KeyboardType = .numeric
    public var fieldFont: UIFont = UIFont.systemFont(ofSize: 20)
    public var secureEntry: Bool = false
    public var hideEnteredText: Bool = false
    public var requireCursor: Bool = true
    public var cursorColor: UIColor = UIColor.blue
    public var fieldSize: CGFloat = 60       // height (and width when fieldWidth == 0)
    public var fieldWidth: CGFloat = 0       // explicit width; 0 = use fieldSize (square)
    public var separatorSpace: CGFloat = 16
    public var fieldBorderWidth: CGFloat = 1
    public var shouldAllowIntermediateEditing: Bool = true
    public var defaultBackgroundColor: UIColor = UIColor.clear
    public var filledBackgroundColor: UIColor = UIColor.clear
    public var defaultBorderColor: UIColor = UIColor.gray
    public var filledBorderColor: UIColor = UIColor.clear
    public var errorBorderColor: UIColor?
    
    public weak var delegate: OTPFieldViewDelegate?
    
    fileprivate var secureEntryData = [String]()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    // Re-position fields whenever Auto Layout resizes us (e.g. after constraints activate)
    override public func layoutSubviews() {
        super.layoutSubviews()
        let w = fieldWidth > 0 ? fieldWidth : fieldSize
        let hasOddNumberOfFields = (fieldsCount % 2 == 1)
        for index in stride(from: 0, to: fieldsCount, by: 1) {
            guard let otpField = viewWithTag(index + 1) as? OTPTextField else { continue }
            let x: CGFloat
            if hasOddNumberOfFields {
                x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * (w + separatorSpace) + w / 2)
            } else {
                x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * w + CGFloat(fieldsCount / 2 - index - 1) * separatorSpace + separatorSpace / 2)
            }
            let y = (bounds.size.height - fieldSize) / 2
            otpField.frame = CGRect(x: x, y: y, width: w, height: fieldSize)
        }
    }

    public func initializeUI() {
        layer.masksToBounds = true
        layoutIfNeeded()
        
        initializeOTPFields()
        
        layoutIfNeeded()
        
        (viewWithTag(1) as? OTPTextField)?.becomeFirstResponder()
    }
    
    fileprivate func initializeOTPFields() {
        secureEntryData.removeAll()
        
        for index in stride(from: 0, to: fieldsCount, by: 1) {
            let oldOtpField = viewWithTag(index + 1) as? OTPTextField
            oldOtpField?.removeFromSuperview()
            
            let otpField = getOTPField(forIndex: index)
            addSubview(otpField)
            
            secureEntryData.append("")
        }
    }
    
    fileprivate func getOTPField(forIndex index: Int) -> OTPTextField {
        let hasOddNumberOfFields = (fieldsCount % 2 == 1)
        let w = fieldWidth > 0 ? fieldWidth : fieldSize   // explicit width or square fallback
        var fieldFrame = CGRect(x: 0, y: 0, width: w, height: fieldSize)

        if hasOddNumberOfFields {
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * (w + separatorSpace) + w / 2)
        }
        else {
            fieldFrame.origin.x = bounds.size.width / 2 - (CGFloat(fieldsCount / 2 - index) * w + CGFloat(fieldsCount / 2 - index - 1) * separatorSpace + separatorSpace / 2)
        }

        fieldFrame.origin.y = (bounds.size.height - fieldSize) / 2
        
        let otpField = OTPTextField(frame: fieldFrame)
        otpField.delegate = self
        otpField.tag = index + 1
        otpField.font = fieldFont
        
        // Set input type for OTP fields
        switch otpInputType {
        case .numeric:
            otpField.keyboardType = .numberPad
        case .alphabet:
            otpField.keyboardType = .alphabet
        case .alphaNumeric:
            otpField.keyboardType = .namePhonePad
        }
        otpField.textColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1) // #282828
        // Set the border values if needed
        otpField.otpBorderColor = defaultBorderColor
        otpField.otpBorderWidth = fieldBorderWidth
        
        if requireCursor {
            otpField.tintColor = cursorColor
        }
        else {
            otpField.tintColor = UIColor.clear
        }
        
        // Set the default background color when text not set
        otpField.backgroundColor = defaultBackgroundColor
        
        // Finally create the fields
        otpField.initalizeUI(forFieldType: displayType)
        
        return otpField
    }
    
    fileprivate func isPreviousFieldsEntered(forTextField textField: UITextField) -> Bool {
        var isTextFilled = true
        var nextOTPField: UITextField?
        
        // If intermediate editing is not allowed, then check for last filled field in forward direction.
        if !shouldAllowIntermediateEditing {
            for index in stride(from: 1, to: fieldsCount + 1, by: 1) {
                let tempNextOTPField = viewWithTag(index) as? UITextField
                
                if let tempNextOTPFieldText = tempNextOTPField?.text, tempNextOTPFieldText.isEmpty {
                    nextOTPField = tempNextOTPField
                    
                    break
                }
            }
            
            if let nextOTPField = nextOTPField {
                isTextFilled = (nextOTPField == textField || (textField.tag) == (nextOTPField.tag - 1))
            }
        }
        
        return isTextFilled
    }
    
    // Helper function to get the OTP String entered
    fileprivate func calculateEnteredOTPSTring(isDeleted: Bool) {
        if isDeleted {
            _ = delegate?.hasEnteredAllOTP(hasEnteredAll: false)
            
            // Set the default enteres state for otp entry
            for index in stride(from: 0, to: fieldsCount, by: 1) {
                var otpField = viewWithTag(index + 1) as? OTPTextField
                
                if otpField == nil {
                    otpField = getOTPField(forIndex: index)
                }
                
                let fieldBackgroundColor = (otpField?.text ?? "").isEmpty ? defaultBackgroundColor : filledBackgroundColor
                let fieldBorderColor = (otpField?.text ?? "").isEmpty ? defaultBorderColor : filledBorderColor
                
                if displayType == .diamond || displayType == .underlinedBottom {
                    otpField?.shapeLayer.fillColor = fieldBackgroundColor.cgColor
                    otpField?.shapeLayer.strokeColor = fieldBorderColor.cgColor
                } else {
                    otpField?.backgroundColor = fieldBackgroundColor
                    otpField?.layer.borderColor = fieldBorderColor.cgColor
                }
            }
        }
        else {
            var enteredOTPString = ""
            
            // Check for entered OTP
            for index in stride(from: 0, to: secureEntryData.count, by: 1) {
                if !secureEntryData[index].isEmpty {
                    enteredOTPString.append(secureEntryData[index])
                }
            }
            
            if enteredOTPString.count == fieldsCount {
                delegate?.enteredOTP(otp: enteredOTPString)
                
                // Check if all OTP fields have been filled or not. Based on that call the 2 delegate methods.
                let isValid = delegate?.hasEnteredAllOTP(hasEnteredAll: (enteredOTPString.count == fieldsCount)) ?? false
                
                // Set the error state for invalid otp entry
                for index in stride(from: 0, to: fieldsCount, by: 1) {
                    var otpField = viewWithTag(index + 1) as? OTPTextField
                    
                    if otpField == nil {
                        otpField = getOTPField(forIndex: index)
                    }
                    
                    if !isValid {
                        // Set error border color if set, if not, set default border color
                        otpField?.layer.borderColor = (errorBorderColor ?? filledBorderColor).cgColor
                    }
                    else {
                        otpField?.layer.borderColor = filledBorderColor.cgColor
                    }
                }
            }
        }
    }
    
}

extension OTPFieldView: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let shouldBeginEditing = delegate?.shouldBecomeFirstResponderForOTP(otpTextFieldIndex: (textField.tag - 1)) ?? true
        if shouldBeginEditing {
            return isPreviousFieldsEntered(forTextField: textField)
        }
        
        return shouldBeginEditing
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        // Check since only alphabet keyboard is not available in iOS
        if !replacedText.isEmpty && otpInputType == .alphabet && replacedText.rangeOfCharacter(from: .letters) == nil {
            return false
        }
        
        if replacedText.count >= 1 {
            // If field has a text already, then replace the text and move to next field if present
            secureEntryData[textField.tag - 1] = string
            
            if hideEnteredText {
                textField.text = " "
            }
            else {
                if secureEntry {
                    textField.text = "•"
                }
                else {
                    textField.text = string
                }
            }
            
            if displayType == .diamond || displayType == .underlinedBottom {
                (textField as! OTPTextField).shapeLayer.fillColor = filledBackgroundColor.cgColor
                (textField as! OTPTextField).shapeLayer.strokeColor = filledBorderColor.cgColor
            }
            else {
                textField.backgroundColor = filledBackgroundColor
                textField.layer.borderColor = filledBorderColor.cgColor
            }
            
            let nextOTPField = viewWithTag(textField.tag + 1)
            
            if let nextOTPField = nextOTPField {
                nextOTPField.becomeFirstResponder()
            }
            else {
                textField.resignFirstResponder()
            }
            
            // Get the entered string
            calculateEnteredOTPSTring(isDeleted: false)
        }
        else {
            let currentText = textField.text ?? ""
            
            if textField.tag > 1 && currentText.isEmpty {
                if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                    deleteText(in: prevOTPField)
                }
            } else {
                deleteText(in: textField)
                
                if textField.tag > 1 {
                    if let prevOTPField = viewWithTag(textField.tag - 1) as? UITextField {
                        prevOTPField.becomeFirstResponder()
                    }
                }
            }
        }
        
        return false
    }
    
    public func deleteText(in textField: UITextField) {
        // If deleting the text, then move to previous text field if present
        secureEntryData[textField.tag - 1] = ""
        textField.text = ""
        
        if displayType == .diamond || displayType == .underlinedBottom {
            (textField as! OTPTextField).shapeLayer.fillColor = defaultBackgroundColor.cgColor
            (textField as! OTPTextField).shapeLayer.strokeColor = defaultBorderColor.cgColor
        } else {
            textField.backgroundColor = defaultBackgroundColor
            textField.layer.borderColor = defaultBorderColor.cgColor
        }
        
        textField.becomeFirstResponder()
        
        // Get the entered string
        calculateEnteredOTPSTring(isDeleted: true)
    }
}
