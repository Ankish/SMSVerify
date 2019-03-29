//
//  ProviderProtocol.swift
//  SmsVerification
//
//  Created by Ankish Jain on 3/8/19.
//  Copyright © 2019 Ankish Jain. All rights reserved.
//

import Foundation

/// This protocol used to controls the OTP Verification flow by passing the proper messages to the library whenever the response
/// of a request which developer created.
protocol OTPStatusControlProtocol : class {
    
    /// This method will allow developer to show alerts on Framework screen.
    ///
    /// - Parameters:
    ///   - title: title string to be displayed in Alert
    ///   - message: message string to be displayed in Alert
    func showAlert(title : String,message : String)
    
    /// This method will allow developer to dismiss the screen.
    ///
    func dismiss()
    
    /// This method will allow developer to do open the validation controller once
    /// they get success response from OTP generate api
    ///
    func didOTPSentSuccessfully()
    
    /// This will reset the remaining timer.
    ///
    func didResentOTPSuccessfully()
}
