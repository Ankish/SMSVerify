//
//  VerificationProtocol.swift
//  SmsVerification
//
//  Created by Plivo on 2/20/19.
//  Copyright © 2019 Plivo. All rights reserved.
//

import Foundation


/// This is a required protocol used for configuring all the requests and response for the sending the OTP message and
/// verification.Controlling the OTP verification flow via OTPStatusControlProtocol.
protocol OTPRequestResponseProtocol : class {
    
    /// Called when a user entered the Country Code and Mobile Number.
    /// This method will allow developer to consume the country code and mobile number and
    /// generate a URLRequest which will generate and send the OTP.
    ///
    /// - Parameters:
    ///   - countryCode: Country Extension number ex: 91,1,etc.
    ///   - mobileNumber: Mobile number to which OTP need to send.
    ///
    /// - Returns: URL Request which will send OTP to the provided Mobile Number.
    func requestForOTPGeneration(countryCode : String,mobileNumber : String) -> URLRequest
    
    /// Called when a user entered the Verification Code which sent to them.
    /// This method will allow developer to consume the verification code and
    /// generate a URLRequest which will validate the code entered by user.
    ///
    /// - Parameters:
    ///   - code: Verification code entered by the User.
    ///
    /// - Returns: URL Request which validate the code which user entered.
    func requestForOTPVerification(_ code : String) -> URLRequest
    
    /// Called when a user click RESEND.
    /// This method will allow developer to consume the country code and mobile number and
    /// generate a URLRequest which will generate and re-send the OTP.
    ///
    /// - Parameters:
    ///   - countryCode: Country Extension number ex: 91,1,etc.
    ///   - mobileNumber: Mobile number to which OTP need to send.
    ///   - retryCount: Number of previous attempts.
    ///
    /// - Returns: URL Request which will send OTP to the provided Mobile Number.
    func requestForOTPResent(countryCode : String,mobileNumber : String,retryCount : Int) -> URLRequest
    
    
    /// Called when a user click CALL.
    /// This method will allow developer to consume the country code and mobile number and
    /// generate a request for Call through which validation code will sent.
    ///
    /// - Parameters:
    ///   - countryCode: Country Extension number ex: 91,1,etc.
    ///   - mobileNumber: Mobile number to which OTP need to send.
    ///
    func requestForCall(countryCode : String,mobileNumber : String)
    
    /// Called when response of OTP generate api received.
    /// This method will allow developer to do appropriate step based on the responseData and responseCode.
    /// if it is true, then need to move forward with validation screen, else error handle should taken care.
    ///
    /// - Parameters:
    ///   - code: Response status Code
    ///   - responseData : Response data of the OTP generate api.
    ///
    func responseForOTPGeneration(responseCode : Int,responseData : Data?)
    
    /// Called when response of OTP submission api received.
    /// This method will allow developer to do appropriate step based on the responseData and responseCode.
    /// if it is true, that means OTP has been validated successfully so need to dismiss the screen, else error handle should taken care.
    ///
    /// - Parameters:
    ///   - code: Response status Code
    ///   - responseData : Response data of the OTP validation api.
    ///
    func responseForOTPVerification(responseCode : Int,responseData : Data?)
    
    /// Called when response of OTP resend api received.
    /// This method will allow developer to do appropriate step based on the responseData and responseCode.
    /// if it is true, then need to reset the timer in validation screen, else error handle should taken care.
    ///
    /// - Parameters:
    ///   - code: Response status Code
    ///   - responseData : Response data of the OTP resend api.
    ///
    func responseForOTPResent(responseCode : Int,responseData : Data?)
}

