//
//  SmsVerificationUITests.swift
//  SmsVerificationUITests
//
//  Created by Ankish on 4/6/19.
//  Copyright © 2019 Ankish. All rights reserved.
//

import XCTest
@testable import SmsVerification
@testable import libPhoneNumber_iOS

class SmsVerificationTests: XCTestCase {
    
    var developerContoller : DeveloperViewController!
    var otpGenerateController: OTPGenerationController!
    var delegate : OTPStatusControlProtocol?
    var otpVerificationController : OTPVerificationController!
    var navigationController : UINavigationController!
    
    let phoneNumber = "97105 19825"
    let sanitizedNumber = "9710519825"
    let countryCode = "+91"
    let countryLocale = "IN"
    let countryName = "India"
    var otpRequestId : String = ""
    
    override func setUp() {
        super.setUp()
        
        //Initializing the developer controller
        developerContoller = DeveloperViewController()
        UIApplication.shared.keyWindow?.rootViewController = developerContoller
        
        //Setting the properties
        developerContoller.properties.backgroundColor = UIColor.white
        developerContoller.properties.tintColor = UIColor.init(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
        developerContoller.properties.confirmButtonBackgroundColor = UIColor.init(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
        developerContoller.properties.textFieldTextColor = UIColor.black
        developerContoller.properties.titleColor = UIColor.black
        developerContoller.properties.hintColor = UIColor.black.withAlphaComponent(0.9)
        developerContoller.properties.hintFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        developerContoller.properties.logoHeight = 70
        developerContoller.properties.verificationCodeKeyboardType = UIKeyboardType.numberPad
        
        //Initializing the OTP generation controller
        let vc = developerContoller.openInitialController()
        self.navigationController = vc
        delegate = vc as? OTPStatusControlProtocol
        otpGenerateController = vc.topViewController as? OTPGenerationController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*
     * Test cases to evaluate the conversion of raw Phone number to formatted and vice versa.
     */
    func testFormatViewController() {
        otpGenerateController.selectedRegionCode = "IN"
        let formattedNumber = otpGenerateController.getValidPhoneNumber(phoneNumber : phoneNumber)
        XCTAssertEqual(formattedNumber, self.sanitizedNumber)
        
        
        let formatter = NBAsYouTypeFormatter(regionCode: "IN")
        let number = formatter?.inputString(sanitizedNumber) ?? ""
        otpGenerateController.selectedRegionCode = "IN"
        XCTAssertEqual(number, self.phoneNumber)
        
        
        XCTAssertNotEqual(number, sanitizedNumber)
    }
    
    /*
     * Test cases to evaluate assigned properties by checking the OTP generation controller UI Components.
     */
    func testOTPGenerationProperties() {
        XCTAssertEqual(otpGenerateController.view.backgroundColor!, developerContoller.properties.backgroundColor)
        
        XCTAssertEqual(otpGenerateController.initiateView.headerView.titleLabel.textColor!, developerContoller.properties.titleColor)
        
        XCTAssertEqual(otpGenerateController.initiateView.phoneTextField.textField.textColor!, developerContoller.properties.textFieldTextColor)
        
        XCTAssertEqual(otpGenerateController.initiateView.phoneTextField.countryCodeUnderline.backgroundColor!, developerContoller.properties.tintColor)
        
        XCTAssertEqual(otpGenerateController.initiateView.verifyButton.backgroundColor!, developerContoller.properties.tintColor)
    }
    
    /*
     * Test cases to check verify button action.
     */
    func testOTPVerification() {
        //Test case for failure response for OTP generation
        otpGenerateController.didSelectCountryCode(countryCodeInfo: CountryCodeInfo(name: countryName,dialCode : countryCode,code : countryLocale,search : ""))
        otpGenerateController.initiateView.phoneTextField.textField.text = phoneNumber
        
        let failureResponse = HTTPURLResponse(url: URL(string: "http://13.57.35.251:5000/v1/otp/generate/")!, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: nil)!
        Service.shared.session = URLSessionMock(mockResponse: failureResponse, responseData: nil)
        otpGenerateController.verifyButtonPressed()
        wait(for: 2)
        XCTAssert(!(navigationController.topViewController is OTPVerificationController))
        
        
        //Test case for success response for OTP generation
        let otpGenerationResponseData = "{ \"data\": { \"expiry_seconds\": 5,\"max_retries\": 2,\"request_id\":\"OTE5NzEwNTE5ODI1PDc5MDI1MTQ2\"},\"status\": true}"
        let successResponse = HTTPURLResponse(url: URL(string: "http://13.57.35.251:5000/v1/otp/generate/")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        Service.shared.session = URLSessionMock(mockResponse: successResponse, responseData: otpGenerationResponseData)
        otpGenerateController.verifyButtonPressed()
        wait(for: 2)
        otpVerificationController = (navigationController.topViewController as? OTPVerificationController)
        XCTAssert(navigationController.topViewController is OTPVerificationController)
        
        otpVerificationController.finalizeView.securityCodeTextField.textField.text = "12345"
        
        
        //Test cases to evaluate assigned properties by checking the OTP verification controller UI Components.
        XCTAssertEqual(otpVerificationController.view.backgroundColor!, developerContoller.properties.backgroundColor)
        
        XCTAssertEqual(otpVerificationController.finalizeView.headerView.titleLabel.textColor!, developerContoller.properties.titleColor)
        
        XCTAssertEqual(otpVerificationController.finalizeView.securityCodeTextField.textField.textColor!, developerContoller.properties.textFieldTextColor)
        
        XCTAssertEqual(otpVerificationController.finalizeView.securityCodeTextField.textUnderline.backgroundColor!, developerContoller.properties.tintColor)
        
        XCTAssertEqual(otpVerificationController.finalizeView.verifySecurityCodeButton.backgroundColor!, developerContoller.properties.confirmButtonBackgroundColor)
        
        
        //Test case for Resend button enable after expiry_seconds completed
        XCTAssertEqual(otpVerificationController!.countryCode,countryCode)
        otpVerificationController.finalizeView.startTimer()
        XCTAssert(!otpVerificationController.finalizeView.resendSecurityCodeButton.isEnabled)
        wait(for: 5)
        XCTAssert(otpVerificationController.finalizeView.resendSecurityCodeButton.isEnabled)
        
        
        //Test case for Resend button max try use cases.
        let resendSuccessData = "{ \"data\": { \"expiry_seconds\": 5,\"max_retries\": 2,\"request_id\":\"OTE5NzEwNTE5ODI1PDc5MDI1MTQ2\"},\"status\": true}"
        Service.shared.session = URLSessionMock(mockResponse: successResponse, responseData: resendSuccessData)
        //First resend
        otpVerificationController.resendSecurityCode()
        otpVerificationController.finalizeView.startTimer()
        XCTAssert(!otpVerificationController.finalizeView.resendSecurityCodeButton.isEnabled)
        wait(for: 5)
        
        XCTAssert(otpVerificationController.finalizeView.resendSecurityCodeButton.isEnabled)
        //Second resend
        otpVerificationController.resendSecurityCode()
        otpVerificationController.finalizeView.startTimer()
        XCTAssert(!otpVerificationController.finalizeView.resendSecurityCodeButton.isEnabled)
        wait(for: 5)
        
        XCTAssert(otpVerificationController.finalizeView.resendSecurityCodeButton.isEnabled)
        //Third resend
        otpVerificationController.resendSecurityCode()
        wait(for: 5)
        XCTAssert(otpVerificationController.finalizeView.resendSecurityCodeButton.isEnabled)
        
        
        //Test case for OTP verification Failure
        let failure = HTTPURLResponse(url: URL(string: "http://13.57.35.251:5000/v1/otp/validate/")!, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: nil)!
        Service.shared.session = URLSessionMock(mockResponse: failure, responseData: nil)
        otpVerificationController.verifyButtonPressed()
        wait(for: 2)
        XCTAssert((navigationController.topViewController is OTPVerificationController))
        
        //Test case for OTP verification Success
        let otpVerificationSuccessResponseData = "{\"data\": { \"validity\": true }, \"status\": true}"
        let success = HTTPURLResponse(url: URL(string: "http://13.57.35.251:5000/v1/otp/validate/")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        Service.shared.session = URLSessionMock(mockResponse: success, responseData: otpVerificationSuccessResponseData)
        otpVerificationController.verifyButtonPressed()
        wait(for: 2)
        XCTAssert((navigationController.topViewController is OTPVerificationController))
    }
    
}

extension XCTestCase {
    
    func wait(for duration: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting")
        
        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            waitExpectation.fulfill()
        }
        
        // We use a buffer here to avoid flakiness with Timer on CI
        waitForExpectations(timeout: duration + 0.5)
    }
}

class URLSessionMock: URLSession {
    private let mockResponse: HTTPURLResponse
    private let responseData : String?
    
    init(mockResponse: HTTPURLResponse,responseData : String?) {
        self.mockResponse = mockResponse
        self.responseData = responseData
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        let data = responseData?.data(using: .utf8)
        return URLSessionDataTaskMock {
            completionHandler(data, self.mockResponse, nil)
        }
        
    }
    
    
}

// We create a partial mock by subclassing the original class
class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}
