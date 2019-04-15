//
//  Properties.swift
//  AppVerifyDemo
//
//  Created by Plivo on 2/18/19.
//  Copyright © 2019 Plivo. All rights reserved.
//

import UIKit

open class Properties {

    public enum TimerType : Int {
        case circle = 0
        case text = 1
    }

    /**
    tint Color used to change the line splitter , navigation bar button and default color to all buttons.
    */
    public var tintColor : UIColor = UIColor.red
    /**
     background color for the screens
     */
    public var backgroundColor : UIColor = UIColor.white
    
    
    
    //title Properties
    /**
     title String which is present on top of first screen
    */
    public var sendTitle : String = "Request OTP"
    /**
     title String which is present on top of second screen
     */
    public var verifyTitle : String = "Verify OTP"
    /**
    title Font which is present on top of the screen
    */
    public var titleFont : UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    /**
     title color which is present on top of the screen
     */
    public var titleColor : UIColor = UIColor.black
    
    
    
    //logo Properties
    /**
     set your app Logo
     */
    public var logo : UIImage? = UIImage(named: "logo")
    /**
     logo Image height
     */
    public var logoHeight : CGFloat = 70
    
    
    
    //textField Properties
    /**
     textField text color,default is black.
     */
    public var textFieldTextColor : UIColor = UIColor.black
    /**
     textField text font.
     */
    public var textFieldFont : UIFont = UIFont.systemFont(ofSize: 24, weight: .medium)
    /**
     textField placeholder color.
    */
    public var textFieldPlaceholderColor : UIColor = UIColor.lightGray
    
    
    //Confirm Button Properties
    /**
     Button title of code validation screen.
     */
    public var confirmButtonTitle : String = "Confirm"
    /**
     Button background color of code validation screen.
     */
    public var confirmButtonBackgroundColor : UIColor = UIColor.green
    
    
    
    //Verify Button Properties
    /**
     Button title of phone number entry screen.
     */
    public var verifyButtonTitle : String = "Verify"
    /**
     Button background color of phone number entry screen.
     */
    public var verifyButtonBackgroundColor : UIColor?
    
    
    
    //Verify Code Keyboard Type
    /**
     Keyboard type for the verification code textField.
     */
    public var verificationCodeKeyboardType : UIKeyboardType = .default
    
    
    
    //Resend Button Properties
    /**
     Title string for the resend button
     */
    public var resendButtonTitle : String = "Resend"
    /**
     Title color for the resend button
     */
    public var resendButtonColor : UIColor?
    /**
     resend hint title
     */
    public var resendHintTitle : String = "Didn't receieve the OTP?"
    /**
     Title string for the call button
     */
    public var callButtonTitle : String = "Call"
    /**
     Title color for the call button
     */
    public var callButtonTitleColor : UIColor?
    /**
     isCallButtonNeeded used to show/hide the Call button which is alternate way for sending the verification code.
     */
    public var isCallButtonNeeded : Bool = false
    /**
     Or label text color, which shows up in between of resend and call button.
     */
    public var orLabelTextColor : UIColor = .black
    /**
     or label text, which shows up in between of resend and call button.
     */
    public var orLabelText : String = "Or"
    
    
    //Hint Text Properties
    /**
     Phone number entry screen hint text
     */
    public var verifyScreenHintText : String = "Phone number"
    /**
     Phone number entry screen hint text
     */
    public var countryCodeHintText : String = "Country Code"
    /**
     Code validation screen hint text
     */
    public var confirmScreenHintText : String = "Enter Security code sent to %@"
    /**
     hint text font which is used in verification ,country code picker and generation screen.
     */
    public var hintFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    /**
     hint text color which is used in verification ,country code picker and generation screen.
     */
    public var hintColor = UIColor.darkGray
    
    
    /**
     error text font
     */
    public var errorFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    /**
     error text color
     */
    public var errorColor = UIColor.red
    
    
    //Cancel Button Text
    /**
     Cancel text which used to set title as navigation bar's bar button item.
     */
    public var cancelText : String = "Cancel"
    
    //provide attribute string which need to show below verify button for privacy and terms policy
    //example:
    
    /*let description = "By Pressing Verify you are agree to our "
    let attributeText : NSMutableAttributedString = NSMutableAttributedString(string: description)
    
    let termsAndConditionString = NSMutableAttributedString(string:  "Terms & Conditions")
    let termsUrl = URL(string: "https://www.google.com")!
    termsAndConditionString.setAttributes([.link: termsUrl], range: NSMakeRange(0, termsAndConditionString.length))
    attributeText.append(termsAndConditionString)
    
    let andText =  NSMutableAttributedString(string: NSLocalizedString(" and ",comment : ""))
    attributeText.append(andText)
    
    let privacyString = NSMutableAttributedString(string:  "Privacy & Policy")
    let privacyUrl = URL(string: "https://www.google.com")!
    privacyString.setAttributes([.link: privacyUrl], range: NSMakeRange(0, privacyString.length))
    attributeText.append(privacyString)
    */
    /**
     Specify any additional information like privacy policy or terms and Conditions with thier links.
     */
    public var urlSupportInfoAttributedString : NSAttributedString?
    
    
    //Enables the resend button after timeout (in Seconds)
    /**
     Resend button enable time in seconds
     */
    public var timeout : CGFloat = 5
    /**
     stroke color for completed timer
     */
    public var timerCompletedStrokeColor: UIColor?
    /**
     Fill color for completed timer
     */
    public var timerCompletedFillColor: UIColor = .green
    /**
     Fill color for uncompleted timer
     */
    public var timerUnCompletedCircleStrokeColor: UIColor = .red
    /**
     Fill color for uncompleted timer
     */
    public var timerUnCompletedCircleFillColor: UIColor = .white
    /**
     Text color for the timer
     */
    public var timerTextColor : UIColor = .black
    /**
     UI type for the timer which display in verification screen
     */
    public var timerType : TimerType = .text
    
    /**
     Retries Maximum count,once retries is exceeded then this count then user can't generate and send the verification code through resend button.
     */
    public var maxRetries : Int = 3
}
