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
    tint Color for entire View
    */
    public var tintColor : UIColor = UIColor.red
    /**
     background color for the screens
     */
    public var backgroundColor : UIColor = UIColor.white
    
    
    
    //title Properties
    /**
     title String which present top of first screen
    */
    public var sendTitle : String = "Request OTP"
    /**
     title String which present top of second screen
     */
    public var verifyTitle : String = "Verify OTP"
    /**
    title Font which present top of the screen
    */
    public var titleFont : UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    /**
     title color which present top of the screen
     */
    public var titleColor : UIColor = UIColor.black
    
    
    
    //logo Properties
    /**
     image for the logoImage view
     */
    public var logo : UIImage? = UIImage(named: "logo")
    /**
     logo Image View height
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
     Keyboard type for the CODE textView.
     */
    public var codeKeyboardType : UIKeyboardType = .default
    
    
    
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
     resedn hint title
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
     Call button need to show or not after time out.
     */
    public var isCallButtonNeed : Bool = false
    /**
     Or label text color.
     */
    public var orLabelTextColor : UIColor = .black
    /**
     or label text.
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
     hint text font
     */
    public var hintFont = UIFont.systemFont(ofSize: 11, weight: .regular)
    /**
     hint text color
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
     Cancel button text
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
    public var urlSupportInfo : NSAttributedString?
    
    
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
     UI type for the timer
     */
    public var timerType : TimerType = .text
    
    /**
     Retries Max count.
     */
    public var maxRetries : Int = 3
}
