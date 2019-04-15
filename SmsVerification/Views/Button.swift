//
//  Button.swift
//  SmsVerification
//
//  Created by Plivo on 2/20/19.
//  Copyright © 2019 Plivo. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        backgroundColor = color
        applyStyling()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyStyling() {
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        layer.cornerRadius = 8
    }
}
