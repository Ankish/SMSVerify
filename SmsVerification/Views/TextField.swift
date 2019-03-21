//
//  TSTextField.swift
//  AppVerifyDemo
//
//  Created by Plivo on 6/18/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

enum TextFieldType {
    case phoneNumber
    case securityCode
}

/**
    Textfield view used to present the vountry code and phone number fields.
 */
class TextField: UIView, UITextFieldDelegate {
    
    struct Constants {
        static let textFieldHeight: CGFloat = 40
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var countryCode: String? {
        didSet {
            countryCodeTextField.text = countryCode
        }
    }
    
    var countryImage : UIImage? {
        didSet {
            countryImageView?.image = countryImage
        }
    }
    
    var countryImageView : UIImageView?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = properties.hintFont
        label.textColor = properties.hintColor
        return label
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = properties.errorFont
        label.textColor = properties.errorColor
        return label
    }()
    
    lazy var countryCodeLabel : UILabel = {
        let label = UILabel()
        label.text = properties.countryCodeHintText
        label.font = properties.hintFont
        label.textColor = properties.hintColor
        return label
    }()
    
    lazy var countryCodeTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textAlignment = .center
        textField.font = properties.textFieldFont
        textField.textColor = properties.textFieldTextColor
        
        let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 20)))
        textField.leftView = imageView
        textField.leftViewMode = .always
        imageView.image = countryImage
        self.countryImageView = imageView
        
        return textField
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = properties.textFieldTextColor
        textField.font = properties.textFieldFont
        return textField
    }()
    
    lazy var countryCodeUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = properties.tintColor
        return view
    }()
    
    lazy var textUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = properties.tintColor
        return view
    }()
    
    var textFieldType: TextFieldType = .phoneNumber
    var properties : Properties
    
    init(title: String, type: TextFieldType,properties : Properties) {
        self.properties = properties
        super.init(frame: .zero)
        
        titleLabel.text = title
        textFieldType = type

        applyStyling()
        setupSubviews()
    }
    
    override init(frame: CGRect) {
        self.properties = Properties()
        super.init(frame: frame)
        applyStyling()
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyStyling() {
        backgroundColor = .clear
        
        switch textFieldType {
        case .phoneNumber:
            textField.textContentType = .telephoneNumber
            textField.keyboardType = .phonePad
            textField.textAlignment = .left
        case .securityCode:
            textField.keyboardType = .namePhonePad
            textField.returnKeyType = .done
            textField.textAlignment = .center
        }
        
        textField.textColor = properties.textFieldTextColor
        textField.font = properties.textFieldFont
        textField.delegate = self
    }
    
    private func setupSubviews() {
        [titleLabel, textField, textUnderline, errorLabel].forEach(self.addSubview)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 14)])
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: textUnderline.topAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)])
       

        switch textFieldType {
        case .phoneNumber:
            [countryCodeTextField, countryCodeUnderline,countryCodeLabel].forEach(self.addSubview)
            
            countryCodeTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([countryCodeTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
                countryCodeTextField.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
                countryCodeTextField.widthAnchor.constraint(equalToConstant: 105),
                countryCodeTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
                ])
            
            countryCodeUnderline.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([countryCodeUnderline.leadingAnchor.constraint(equalTo: countryCodeTextField.leadingAnchor),
                countryCodeUnderline.bottomAnchor.constraint(equalTo: textUnderline.bottomAnchor),
                countryCodeUnderline.heightAnchor.constraint(equalToConstant: 2.0),
                countryCodeUnderline.widthAnchor.constraint(equalTo: countryCodeTextField.widthAnchor)
                ])
            
            textField.leadingAnchor.constraint(equalTo: countryCodeTextField.trailingAnchor, constant: 8).isActive = true
            
            countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([countryCodeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                                         countryCodeLabel.topAnchor.constraint(equalTo: topAnchor),
                                         countryCodeLabel.heightAnchor.constraint(equalToConstant: 14),
                                         countryCodeLabel.trailingAnchor.constraint(equalTo: countryCodeTextField.trailingAnchor)])
            titleLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
            
        case .securityCode:
            textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        }

        textUnderline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([textUnderline.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            textUnderline.trailingAnchor.constraint(equalTo: trailingAnchor),
            textUnderline.bottomAnchor.constraint(equalTo: errorLabel.topAnchor),
            textUnderline.heightAnchor.constraint(equalToConstant: 2.0)])
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([errorLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                                     errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
    }
    
    /**
        Removes all non-numeric characters from the country code and phone number, then checks to see if the phone number already contains the country code. If it does, then just the sanitize phone number will be returned. If it does not, the sanitized country code and phone number are combined, then returned.
 
        - Parameter countryCode: Country Code that was selected
        - Parameter phoneNumber: Phone Number that was entered
     
        - Returns: String
    */
    func sanitizePhoneNumber(countryCode: String, phoneNumber: String) -> String {
        
        let sanitizedCountryCode = sanitizeString(string: countryCode)
        let sanitizedPhoneNumber = sanitizeString(string: phoneNumber)
        
        if sanitizedPhoneNumber.prefix(sanitizedCountryCode.count) == sanitizedCountryCode {
            return sanitizedPhoneNumber
        } else {
            return sanitizedCountryCode + sanitizedPhoneNumber
        }
    }
    
    /**
        Takes a phone number as String and removes all non numeric characters
        from it before returning.
     */
    func sanitizeString(string: String) -> String {
        return String(string.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
    func setErrorText(string : String?) {
        self.errorLabel.text = string
        if let string = string,!string.isEmpty {
            textUnderline.backgroundColor = properties.errorColor
        } else {
            textUnderline.backgroundColor = properties.tintColor
        }
    }
}
