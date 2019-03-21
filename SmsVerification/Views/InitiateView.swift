//
//  TSInitiateView.swift
//  AppVerifyDemo
//
//  Created by Plivo on 7/3/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit
import os.log

/**
     The initiate view with country code and phone number field to be verified
     along with the verify button.
 */
class InitiateView: UIView {
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(dismissKeyboard))
        return tap
    }()
    
    lazy var countryCodeTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    let headerView : HeaderView
    let verifyButton : Button
    let phoneTextField : TextField
    
    private let properties : Properties
    private(set) var urlSupportTextView : UITextView?

    init(properties : Properties) {
        self.properties = properties
        self.headerView = HeaderView(properties: properties,title : properties.sendTitle)
        self.verifyButton = Button(title: properties.verifyButtonTitle, color: properties.verifyButtonBackgroundColor ?? properties.tintColor)
        self.phoneTextField = TextField(title: properties.verifyScreenHintText, type: .phoneNumber, properties: properties)
        super.init(frame: .zero)
        applyStyling()
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyStyling() {
        backgroundColor = UIColor.clear
        phoneTextField.countryCodeTextField.text = suggestedCountryCode().0
        phoneTextField.countryImage = suggestedCountryCode().1
        phoneTextField.countryCodeTextField.addGestureRecognizer(countryCodeTapGesture)
    }
    
    private func setupSubviews() {
        [headerView, phoneTextField, verifyButton].forEach(addSubview)
        
        let top : NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            top = safeAreaLayoutGuide.topAnchor
        } else {
            top = self.topAnchor
        }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([ headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                          headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                          headerView.topAnchor.constraint(equalTo: top),
                                          headerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
                                          headerView.heightAnchor.constraint(equalToConstant: self.properties.logoHeight + 40)])
       
        let topPadding : CGFloat
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            topPadding = 60
        } else {
            topPadding = 30
        }
        
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([phoneTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
        phoneTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        phoneTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: topPadding)])
        
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([verifyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
        verifyButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        verifyButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 20),
        verifyButton.heightAnchor.constraint(equalToConstant: 60)])
        
        bringSubviewToFront(headerView)
        addGestureRecognizer(tapGesture)
        
        if let attributedText = properties.urlSupportInfo {
            let textView = UITextView()
            textView.backgroundColor = .clear
            textView.textAlignment = .center
            textView.attributedText = attributedText
            textView.isSelectable = true
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.dataDetectorTypes = [.address,.link,.phoneNumber]
            textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : properties.tintColor,NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
            self.urlSupportTextView = textView
            
            self.addSubview(textView)
            
            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
                textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
                textView.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 20),
                textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10)])
        } else {
            verifyButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
        }
    }
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
    
    /**
        Attempts to get the local country code (ex. "US") by accessing the user's region settings. Then searches the countryCodesArray that is created from the countryCode.json file for the corresponding dial code and returns that value. Defaults to "+1" if no dial code or local country code is found.
     
        - Returns: Suggested country code
    */
    func suggestedCountryCode() -> (String,UIImage?) {
        
        var countryDialCode = "+1"
        var image : UIImage?
        if let imageFile = Bundle.main.path(forResource: "US", ofType: "png") {
           image = UIImage(contentsOfFile: imageFile)
        }
        
        if let isoCountryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {

            var countryCodesArray = [CountryCodeInfo]()
            
            guard let path = Bundle.main.path(forResource: "countryCode", ofType: "json") else { return (countryDialCode,image) }
            let url = URL(fileURLWithPath: path)
            
            do {
                let data = try Data(contentsOf: url)
                countryCodesArray = try JSONDecoder().decode([CountryCodeInfo].self, from: data)
            } catch let error {
                os_log("Failed to decode result for %@", log: Log.error, type: .error, error.localizedDescription)
            }
            
            for countryCodeInfo in countryCodesArray {
                if countryCodeInfo.code == isoCountryCode {
                    countryDialCode = countryCodeInfo.dialCode
                    if let imageFile = Bundle.main.path(forResource: countryCodeInfo.code, ofType: "png") {
                        image = UIImage(contentsOfFile: imageFile)
                    }
                }
            }
            
            return (countryDialCode,image)
        } else {
            return (countryDialCode,image)
        }
    }
}
