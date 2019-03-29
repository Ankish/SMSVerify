[![Plivo iOS Sample App](https://github.com/Ankish/SMSVerify/blob/master/Media/Simulator%20Screen%20Shot%20-%20iPhone%206%20-%202019-03-27%20at%2017.35.37.png)](https://www.plivo.com) [![Plivo iOS Sample App](https://github.com/Ankish/SMSVerify/blob/master/Media/Simulator%20Screen%20Shot%20-%20iPhone%206%20-%202019-03-27%20at%2018.02.02.png)](https://www.plivo.com)

## Overview
This library enables developers to integrate SMS verification flow in an easy way. It provides extensive and easy customization of the UI to fit each app’s need. By configuring the UI and providing requests for `Sending OTP` and `Verify OTP`, the developer can integrate verification flow quickly.

## Dependency 

- Swift Version            -     Swift 4.2
- Xcode Version            -     Xcode 10+
- Deployment target        -     IOS 10.0
- External Library         -     libPhoneNumber-iOS 
([Lib PhoneNumber](https://github.com/iziz/libPhoneNumber-iOS) is used to format and validate the phone number.
You can add “pod 'libPhoneNumber-iOS'” in developer pod file and do ”pod install” from the terminal which will generate the required files of this library.)

## Steps to Integrate

1. Download the repo. Add the [SmsVerification](https://github.com/Ankish/SMSVerify/tree/master/SmsVerification) folder to your app, this contains all the required files.
1. Conform your Viewcontroller (from which you want to start the OTP flow) to [OTPRequestResponseProtocol](https://github.com/Ankish/SMSVerify/blob/master/SmsVerification/Protocol/OTPRequestResponseProtocol.swift). Checkout the [DeveloperViewController](https://github.com/Ankish/SMSVerify/blob/master/DeveloperViewController.swift) for complete implementation.
1. [Configure](https://github.com/Ankish/SMSVerify/blob/master/readme.md#configurable-properties) your UI according to your app theme
1. OTPGenerationController is the base controller which used to start the OTP generation and verification flow. Initialize the OTPGenerationController by calling getInstance() class method with following parameters,

1. Properties - If the developer needs to configure their UI properties, then create Properties object and change the required UI properties and send it as first parameter.
1. OTPRequestResponseProtocol - An object which conforms OTPRequestResponseProtocol protocol 


> **let vc = OTPGenerationController.getInstance(properties : properties,consumerDelegate : self)**
> **self.present(vc, animated: true, completion: nil)**

1. OTPGenerationController.getInstance() method will return a Navigation Controller which conforms the [OTPStatusControlProtocol](https://github.com/Ankish/SMSVerify/blob/master/SmsVerification/Protocol/OTPStatusControlProtocol.swift).Developer needs to store this reference for controlling the OTP verification flow.

> **self.delegate = vc as? OTPStatusControlProtocol**

1. Build and run the project.

## Configurable Properties

Using the Properties object, developer can change the UI properties like tintColor, backgroundColor, font, textColor,  logo, Keyboard Type and localizable the labels and button titles.

For more information on Properties, refer [Properties.Swift](https://github.com/Ankish/SMSVerify/blob/master/SmsVerification/Helper%20Classes/Properties.swift) file.

let properties = Properties()
properties.backgroundColor = UIColor.white
properties.tintColor = UIColor.init(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
properties.confirmButtonBackgroundColor = UIColor.init(red: 67/255, green: 160/255, blue: 71/255, alpha: 1)
properties.textFieldTextColor = UIColor.black
properties.titleColor = UIColor.black


## Protocols:

1. [OTPRequestResponseProtocol](https://github.com/Ankish/SMSVerify/blob/master/SmsVerification/Protocol/OTPRequestResponseProtocol.swift): This is a required protocol used for configuring all the requests and response for the sending the OTP message and verification.Controlling the OTP verification flow via OTPStatusControlProtocol.

- **func requestForOTPGeneration(countryCode : String,mobileNumber : String) -> URLRequest**
> *Called when a user entered the Country Code and Mobile Number and developer needs to generate and 
> *return a URLRequest which will generate and send the OTP to the mobile number which user entered.*


- **func requestForOTPVerification(_ code : String) -> URLRequest**
> *Called when a user entered the Verification Code which sent to them through the above api.
> *Developer needs to generate and return the URLRequest which used to validate the code which entered by user.*


- **func requestForOTPResent(countryCode : String,mobileNumber : String,retryCount : Int) -> URLRequest**
> *Called when a user click RESEND and developer needs to re-generate and return the OTP Generation and Send URLRequest*


- **func requestForCall(countryCode : String,mobileNumber : String)**
> *Called when a user click CALL button which is alternate way for getting the verification code.
> *Developer needs to generate and return a URLRequest which will generate and initiate a call to the mobile number which               > *user entered in which the verification code will deliver.*


- **func responseForOTPGeneration(responseCode : Int,responseData : Data?)**
> *Called when response of OTP generate api received from server.
> *Developer needs to do appropriate step based on the responseData and responseCode.
> *if response is success, then move forward with validation screen, else handle the error.*


- **func responseForOTPVerification(responseCode : Int,responseData : Data?)**
> *Called when response of OTP verification api received from server.
> *Developer needs to do appropriate step based on the responseData and responseCode.
> *if response is success, then dismiss the screen and continue with the user verified flow, else handle the error.*


- **func responseForOTPResent(responseCode : Int,responseData : Data?)**
> *Called when response of OTP resend api received from server.*
> *Developer needs to do appropriate step based on the responseData and responseCode.*
> *if response is success, then reset the timer in validation screen, else handle the error.*


2. [OTPStatusControlProtocol](https://github.com/Ankish/SMSVerify/blob/master/SmsVerification/Protocol/OTPStatusControlProtocol.swift): This protocol used to controls the OTP Verification flow by passing the proper messages to the library whenever the response of a request which developer created.

- **func didOTPSentSuccessfully()**
> *Developer needs to call this method when they get success response in OTP generation.*


- **func didResentOTPSuccessfully()**
> *Developer needs to call this method when they get success response in OTP re-generation.*
